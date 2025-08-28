from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import List, Dict, Any, Optional
from fastapi import HTTPException

from models.rbac_models import Role, Permission, UserPermission
from models.user import User
from service.security_service import SecurityService


class RBACService:
    def __init__(self, db: Session):
        self.db = db
        self.security_service = SecurityService(db)
    
    def create_role(self, name: str, description: str = None, permissions: List[int] = None) -> Role:
        """Create a new role."""
        # Check if role already exists
        existing_role = self.db.query(Role).filter(Role.name == name).first()
        if existing_role:
            raise HTTPException(status_code=400, detail="Role already exists")
        
        role = Role(name=name, description=description)
        self.db.add(role)
        self.db.commit()
        self.db.refresh(role)
        
        # Add permissions if provided
        if permissions:
            self.add_permissions_to_role(role.id, permissions)
        
        return role
    
    def create_permission(self, name: str, resource: str, action: str, description: str = None) -> Permission:
        """Create a new permission."""
        # Check if permission already exists
        existing_permission = self.db.query(Permission).filter(
            and_(
                Permission.resource == resource,
                Permission.action == action
            )
        ).first()
        
        if existing_permission:
            raise HTTPException(status_code=400, detail="Permission already exists")
        
        permission = Permission(
            name=name,
            resource=resource,
            action=action,
            description=description
        )
        
        self.db.add(permission)
        self.db.commit()
        self.db.refresh(permission)
        
        return permission
    
    def assign_role_to_user(self, user_id: int, role_id: int, granted_by: int = None) -> bool:
        """Assign a role to a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        role = self.db.query(Role).filter(Role.id == role_id).first()
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if not role:
            raise HTTPException(status_code=404, detail="Role not found")
        
        if role not in user.roles:
            user.roles.append(role)
            self.db.commit()
            
            # Log the event
            self.security_service.log_audit_event(
                user_id=user_id,
                action="role_assigned",
                resource=f"/rbac/roles/{role_id}",
                metadata={"role_name": role.name, "granted_by": granted_by}
            )
        
        return True
    
    def remove_role_from_user(self, user_id: int, role_id: int) -> bool:
        """Remove a role from a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        role = self.db.query(Role).filter(Role.id == role_id).first()
        
        if not user or not role:
            raise HTTPException(status_code=404, detail="User or role not found")
        
        if role in user.roles:
            user.roles.remove(role)
            self.db.commit()
            
            # Log the event
            self.security_service.log_audit_event(
                user_id=user_id,
                action="role_removed",
                resource=f"/rbac/roles/{role_id}",
                metadata={"role_name": role.name}
            )
        
        return True
    
    def add_permissions_to_role(self, role_id: int, permission_ids: List[int]) -> bool:
        """Add permissions to a role."""
        role = self.db.query(Role).filter(Role.id == role_id).first()
        if not role:
            raise HTTPException(status_code=404, detail="Role not found")
        
        permissions = self.db.query(Permission).filter(Permission.id.in_(permission_ids)).all()
        
        for permission in permissions:
            if permission not in role.permissions:
                role.permissions.append(permission)
        
        self.db.commit()
        return True
    
    def remove_permissions_from_role(self, role_id: int, permission_ids: List[int]) -> bool:
        """Remove permissions from a role."""
        role = self.db.query(Role).filter(Role.id == role_id).first()
        if not role:
            raise HTTPException(status_code=404, detail="Role not found")
        
        permissions = self.db.query(Permission).filter(Permission.id.in_(permission_ids)).all()
        
        for permission in permissions:
            if permission in role.permissions:
                role.permissions.remove(permission)
        
        self.db.commit()
        return True
    
    def grant_permission_to_user(self, user_id: int, permission_id: int, 
                                granted_by: int = None, expires_at: str = None) -> bool:
        """Grant a specific permission to a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        permission = self.db.query(Permission).filter(Permission.id == permission_id).first()
        
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        if not permission:
            raise HTTPException(status_code=404, detail="Permission not found")
        
        # Check if permission already granted
        existing = self.db.query(UserPermission).filter(
            and_(
                UserPermission.user_id == user_id,
                UserPermission.permission_id == permission_id,
                UserPermission.is_active == True
            )
        ).first()
        
        if existing:
            raise HTTPException(status_code=400, detail="Permission already granted")
        
        user_permission = UserPermission(
            user_id=user_id,
            permission_id=permission_id,
            granted_by=granted_by,
            expires_at=expires_at
        )
        
        self.db.add(user_permission)
        self.db.commit()
        
        # Log the event
        self.security_service.log_audit_event(
            user_id=user_id,
            action="permission_granted",
            resource=f"/rbac/permissions/{permission_id}",
            metadata={"permission_name": permission.name, "granted_by": granted_by}
        )
        
        return True
    
    def revoke_permission_from_user(self, user_id: int, permission_id: int) -> bool:
        """Revoke a specific permission from a user."""
        user_permission = self.db.query(UserPermission).filter(
            and_(
                UserPermission.user_id == user_id,
                UserPermission.permission_id == permission_id,
                UserPermission.is_active == True
            )
        ).first()
        
        if not user_permission:
            raise HTTPException(status_code=404, detail="Permission not found")
        
        user_permission.is_active = False
        self.db.commit()
        
        # Log the event
        self.security_service.log_audit_event(
            user_id=user_id,
            action="permission_revoked",
            resource=f"/rbac/permissions/{permission_id}"
        )
        
        return True
    
    def check_permission(self, user_id: int, resource: str, action: str) -> bool:
        """Check if a user has a specific permission."""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return False
        
        # Check role-based permissions
        for role in user.roles:
            if not role.is_active:
                continue
            
            for permission in role.permissions:
                if not permission.is_active:
                    continue
                
                if permission.resource == resource and permission.action == action:
                    return True
        
        # Check direct user permissions
        user_permissions = self.db.query(UserPermission).join(Permission).filter(
            and_(
                UserPermission.user_id == user_id,
                UserPermission.is_active == True,
                Permission.resource == resource,
                Permission.action == action,
                Permission.is_active == True
            )
        ).all()
        
        return len(user_permissions) > 0
    
    def get_user_permissions(self, user_id: int) -> List[Dict[str, Any]]:
        """Get all permissions for a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        permissions = set()
        
        # Get role-based permissions
        for role in user.roles:
            if role.is_active:
                for permission in role.permissions:
                    if permission.is_active:
                        permissions.add((permission.resource, permission.action, permission.name))
        
        # Get direct user permissions
        user_permissions = self.db.query(UserPermission).join(Permission).filter(
            and_(
                UserPermission.user_id == user_id,
                UserPermission.is_active == True,
                Permission.is_active == True
            )
        ).all()
        
        for user_permission in user_permissions:
            permission = user_permission.permission
            permissions.add((permission.resource, permission.action, permission.name))
        
        return [
            {
                "resource": resource,
                "action": action,
                "name": name
            }
            for resource, action, name in permissions
        ]
    
    def get_user_roles(self, user_id: int) -> List[Dict[str, Any]]:
        """Get all roles for a user."""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return []
        
        return [
            {
                "id": role.id,
                "name": role.name,
                "description": role.description
            }
            for role in user.roles
            if role.is_active
        ]
    
    def get_all_roles(self) -> List[Dict[str, Any]]:
        """Get all roles."""
        roles = self.db.query(Role).filter(Role.is_active == True).all()
        
        return [
            {
                "id": role.id,
                "name": role.name,
                "description": role.description,
                "permissions": [
                    {
                        "id": permission.id,
                        "name": permission.name,
                        "resource": permission.resource,
                        "action": permission.action
                    }
                    for permission in role.permissions
                    if permission.is_active
                ]
            }
            for role in roles
        ]
    
    def get_all_permissions(self) -> List[Dict[str, Any]]:
        """Get all permissions."""
        permissions = self.db.query(Permission).filter(Permission.is_active == True).all()
        
        return [
            {
                "id": permission.id,
                "name": permission.name,
                "resource": permission.resource,
                "action": permission.action,
                "description": permission.description
            }
            for permission in permissions
        ]
