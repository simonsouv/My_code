from web_classes import WebPage
from bb_ref_team import Team
from common import get_logger

logger = get_logger(__name__)

team_url = 'https://www.basketball-reference.com/teams/TOR/2019.html'
page = WebPage.get_page(team_url, output='bs')
team_info = Team.get_team_info_header_bs(page)

team = Team(team_info)
logger.info("%s" % team.__str__())
