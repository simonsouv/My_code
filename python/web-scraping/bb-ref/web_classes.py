from bs4 import BeautifulSoup
from urllib2 import urlopen
from urllib2 import HTTPError
from urllib2 import URLError
from common import timer, get_logger
from lxml import etree
import time

logger = get_logger(__name__)


class WebPage:
    def __init__(self, url):
        self.url = url

    @staticmethod
    @timer
    def get_page(url, output='text'):
        try:
            start_time = time.time()
            html = urlopen(url)
            run_time = time.time() - start_time
            logger.debug(' urlopen in {:.4f} secs'.format(run_time))
        except HTTPError:
            logger.exception()
            return None
        except URLError:
            logger.exception()
            return None
        else:
            start_time = time.time()
            if output == 'text':
                res = html.read()
            elif output == 'bs':
                res = BeautifulSoup(html, 'lxml')
            elif output == 'lxml':
                res = etree.parse(html, etree.HTMLParser())
            run_time = time.time() - start_time
            logger.debug(' generate res in {:.4f} secs'.format(run_time))
            return res
