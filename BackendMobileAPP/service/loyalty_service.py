import httpx
from fastapi import HTTPException
from sqlalchemy.orm import Session

from config.settings import settings
from utils.logger import get_logger

logger = get_logger()

async def fetch_loyalty_points(
    guest_id: str,
    page_num: int = None,
    num_records: int = None,
    sort_ascending: bool = None,
    view_grooming_points: bool = None,
    expand: str = None,
    db: Session = None

):
    url = f"{settings.ZENOTI_BASE_URL}/v1/guests/{guest_id}/points"

    headers = {
        "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
        "Accept": "application/json"
    }

    params = {}

    if page_num is not None:
        params["page_num"] = page_num
    if num_records is not None:
        params["num_records"] = num_records
    if sort_ascending is not None:
        params["sort_ascending"] = str(sort_ascending).lower()
    if view_grooming_points is not None:
        params["view_grooming_points"] = str(view_grooming_points).lower()
    if expand is not None:
        params["expand[0]"] = expand

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers, params=params)

        if response.status_code == 200:
            logger.info(f"[LOYALTY] Success for guest_id: {guest_id}")
            return response.json()

        elif response.status_code == 404:
            raise HTTPException(status_code=404, detail="Guest not found")

        elif response.status_code == 400:
            raise HTTPException(status_code=400, detail="Invalid request parameters")

        else:
            logger.error(f"[LOYALTY] Zenoti API error: {response.status_code} - {response.text}")
            raise HTTPException(status_code=500, detail="Failed to fetch loyalty points")

    except httpx.RequestError as exc:
        logger.exception(f"[LOYALTY] Request failed: {exc}")
        raise HTTPException(status_code=500, detail="Internal connection error")
    

    
async def fetch_loyalty_points_by_type(guest_id: str, type: int, invoice_id: str):
    logger.info(f"[LOYALTY-TYPE] Calling Zenoti: guest_id={guest_id}, type={type}, invoice_id={invoice_id}")

    url = f"{settings.ZENOTI_BASE_URL}/v1/guests/{guest_id}/points/{type}"

    headers = {
        "Authorization": f"apikey {settings.ZENOTI_API_KEY}",
        "accept": "application/json"
    }
    params = {
        "invoice_id": invoice_id
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers, params=params)
            logger.info(f"HTTP Request: GET {response.url} \"{response.status_code}\"")

            if response.status_code != 200:
                logger.error(f"[LOYALTY-TYPE] Zenoti API Error: {response.status_code} - {response.text}")
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"Zenoti API error: {response.status_code} - {response.text}"
                )

            data = response.json()
            if not data or data.get("error"):
                logger.error(f"[LOYALTY-TYPE] Error in response: {data}")
                raise HTTPException(status_code=502, detail="Error from Zenoti API")

            # Extract points from response
            points_key = "earned" if type == 0 else "redeemed"
            points_data = data.get("points", {}).get(points_key, [])

            logger.info(f"[LOYALTY-TYPE] Retrieved {points_key} points: {points_data}")
            return points_data

    except Exception as e:
        logger.exception(f"[LOYALTY-TYPE] Exception: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
