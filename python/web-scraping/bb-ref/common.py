import functools
import logging
import logging.config
import time


def get_logger(class_name):
    logger_obj = logging.getLogger(class_name)
    default_logging = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'verbose': {
                'format': '%(asctime)s - %(name)s - %(module)s - %(levelname)s - pid %(process)d - tid %(threadName)s - %(funcName)s - %(message)s',
            },
            'simple': {
                'format': '%(asctime)s - %(levelname)s - %(message)s',
            }
        },
        'handlers': {
            'console': {
                'level': 'INFO',
                'class': 'logging.StreamHandler',
                'stream': 'ext://sys.stdout',
                'formatter': 'simple',
            },
            'file_dbg': {
                'filename': 'dbg.log',
                'mode': 'w',
                'level': 'DEBUG',
                'class': 'logging.FileHandler',
                'formatter': 'verbose'
            },
        },
        'loggers': {
            '': {
                'handlers': ['console', 'file_dbg'],
                'level': 'DEBUG',
            },
            'file': {
                'handlers': ['file_dbg'],
                'level': 'INFO',  # overwrite level set in handlers
                'propagate': False,
            },
            'stdout': {
                'handlers': ['console'],
                'level': 'INFO',
                'propagate': False,
            },
        }
    }
    logging.config.dictConfig(default_logging)
    return logger_obj


def timer(func):
    """Print the runtime of the decorated function"""
    @functools.wraps(func)
    def wrapper_timer(*args, **kwargs):
        start_time = time.time()    # 1
        value = func(*args, **kwargs)
        end_time = time.time()      # 2
        run_time = end_time - start_time    # 3
        logger.debug("Finished {} in {:.4f} secs".format(func.__name__,
                                                         run_time))
        return value
    return wrapper_timer


logger = get_logger(__name__)
