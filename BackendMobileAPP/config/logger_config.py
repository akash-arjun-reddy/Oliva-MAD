import logging
import colorlog

def setup_color_logging(level=logging.DEBUG):
    """
    Configure the root logger to output colored logs.
    Call this once, at app startup.
    """
    handler = colorlog.StreamHandler()
    handler.setLevel(level)
    handler.setFormatter(colorlog.ColoredFormatter(
        "%(log_color)s%(asctime)s [%(levelname)s] %(message)s",
        log_colors={
            'DEBUG':    'cyan',
            'INFO':     'green',
            'WARNING':  'yellow',
            'ERROR':    'red',
            'CRITICAL': 'bold_red',
        }
    ))

    root = colorlog.getLogger()        # wraps the root logger
    root.setLevel(level)
    root.handlers.clear()              # remove any default handlers
    root.addHandler(handler)
    root.propagate = False
