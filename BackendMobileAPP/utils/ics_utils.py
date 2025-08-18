from ics import Calendar, Event
from datetime import datetime
import tempfile
import pytz

def generate_ics_file(appointment):
    print("DEBUG ICS: date=", appointment.date, "start_time=", appointment.start_time, "end_time=", appointment.end_time)
    c = Calendar()
    e = Event()
    e.name = "Oliva Clinic Appointment"
    tz = pytz.timezone("Asia/Kolkata")  # Set your desired timezone
    e.begin = tz.localize(datetime.combine(appointment.date, appointment.start_time))
    e.end = tz.localize(datetime.combine(appointment.date, appointment.end_time))
    e.location = "Online (Video Call)"
    e.description = f"Join your consultation: {appointment.video_call_link}"
    e.status = "confirmed"

    c.events.add(e)

    with tempfile.NamedTemporaryFile(delete=False, suffix=".ics", mode='w') as f:
        f.write(str(c))
        return f.name  # full path of the created .ics file
