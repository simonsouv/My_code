from bb_ref_data import Data
from common import timer, get_logger
import re

logger = get_logger(__name__)


class Team(Data):
    def __init__(self, team_info):
        """
        constructor
        :param team_info: dictionary of info to store
        """
        super(Team, self).__init__()
        self.data['ori_url'] = team_info['ori_url']
        self.data['team'] = team_info['team']
        self.data['coach'] = team_info['coach']
        self.data['year'] = team_info['year']
        self.data['wl'] = team_info['wl']
        self.data['pts'] = team_info['pts']
        self.data['pts_opp'] = team_info['pts_opp']
        self.data['srs'] = team_info['srs']
        self.data['pace'] = team_info['pace']
        self.data['rtg_off'] = team_info['rtg_off']
        self.data['rtg_def'] = team_info['rtg_def']
        self.data['wl_exp'] = team_info['exp_wl']

    def __str__(self):
        output = "Team info:\n"
        for k in sorted(self.data.keys()):
            output += "  %s: %s\n" % (k, self.data[k])
        return output

    @staticmethod
    @timer
    def get_team_info_header_lxml(page):
        """
        return team page header information from a lxml object
        loe stands for list of Elements
        :param page: lxml object containing the webpage information
        :return: dictionary containing set of information
        """
        # get original url
        loe_ori_url = page.xpath("/html/head/meta[@property='og:url']")
        ori_url = loe_ori_url[0].get('content')
        # get year and team name
        loe_sum = page.xpath("/html/body//div[@data-template='Partials/Teams/Summary']")
        year = loe_sum[0].xpath("h1/span")[0].text
        team = loe_sum[0].xpath("h1/span")[1].text
        # get summary info
        loe_sum_txt = loe_sum[0].xpath("p")
        rec = re.search(r'(\d+-\d+)',
                        loe_sum_txt[0].xpath("string()")  # get multi-line text between <p>
                        ).group()
        coach = re.search(r'Coach: (\w+( \w+)*)', loe_sum_txt[1].xpath("string()")).group()
        multi_info = re.search(r'PTS.*?(\d+\.\d+).*Opp.*?(\d+\.\d+)',
                               loe_sum_txt[3].xpath("string()").replace('\n', ''))
        pts = multi_info.group(1)
        pts_opp = multi_info.group(2)
        multi_info = re.search(r'SRS.*?(\d+\.\d+).*Pace.*?(\d+\.\d+)',
                               loe_sum_txt[4].xpath("string()").replace('\n', ''))
        srs = multi_info.group(1)
        pace = multi_info.group(2)
        multi_info = re.search(r'Off Rtg.*?(\d+\.\d+).*Def Rtg.*?(\d+\.\d+)',
                               loe_sum_txt[5].xpath("string()").replace('\n', ''))
        rtg_off = multi_info.group(1)
        rtg_def = multi_info.group(2)
        exp_wl = re.search(r'Exp.*?(\d+-\d+)',
                           loe_sum_txt[6].xpath("string()").replace('\n', '')).group(1)
        return {'ori_url': ori_url,
                'team': team,
                'coach': coach,
                'year': year,
                'wl': rec,
                'pts': pts,
                'pts_opp': pts_opp,
                'srs': srs,
                'pace': pace,
                'rtg_off': rtg_off,
                'rtg_def': rtg_def,
                'exp_wl': exp_wl}

    @staticmethod
    @timer
    def get_team_info_header_bs(page):
        """
        return team page header information from a BeautifulSoup object
        :param page: BeautifulSoup object containing the webpage information
        :return: dictionary containing set of information
        """
        # get original url
        ori_url = page.find('meta', {'property': 'og:url'})['content']
        summary = page.find('div', {'data-template': 'Partials/Teams/Summary'})
        # get year and team name
        title = summary.h1.find_all('span')
        year = title[0].get_text()
        team = title[1].get_text()
        # get summary info
        infos = summary.find_all('p')
        rec = re.search(r'(\d+-\d+)', infos[0].get_text()).group()
        coach = re.search(r'Coach: (\w+( \w+)*)', infos[1].get_text()).group(1)
        line_multi_info = re.search(r'PTS.*?(\d+\.\d+).*Opp.*?(\d+\.\d+)',
                                    infos[3].get_text().replace('\n', ''))
        pts = line_multi_info.group(1)
        pts_opp = line_multi_info.group(2)
        line_multi_info = re.search(r'SRS.*?(\d+\.\d+).*Pace.*?(\d+\.\d+)',
                                    infos[4].get_text().replace('\n', ''))
        srs = line_multi_info.group(1)
        pace = line_multi_info.group(2)
        line_multi_info = re.search(r'Off Rtg.*?(\d+\.\d+).*Def Rtg.*?(\d+\.\d+)',
                                    infos[5].get_text().replace('\n', ''))
        rtg_off = line_multi_info.group(1)
        rtg_def = line_multi_info.group(2)
        exp_wl = re.search(r'Exp.*?(\d+-\d+)',
                           infos[6].get_text().replace('\n', '')).group(1)
        return {'ori_url': ori_url,
                'team': team,
                'coach': coach,
                'year': year,
                'wl': rec,
                'pts': pts,
                'pts_opp': pts_opp,
                'srs': srs,
                'pace': pace,
                'rtg_off': rtg_off,
                'rtg_def': rtg_def,
                'exp_wl': exp_wl}
