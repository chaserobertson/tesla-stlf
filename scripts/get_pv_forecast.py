from bs4 import BeautifulSoup
import requests
import zipfile
import io

DOMAIN = "https://nemweb.com.au"
INDEX_URL = f'{DOMAIN}/Reports/Archive/ROOFTOP_PV/FORECAST/'

def parse_index(index_url):
    response = requests.get(index_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    links = [link.get('href') for link in soup.find_all('a')]
    return links[1:3] # first link on page is not to a zipfile TODO remove 3

def unzip_week(link):
    response = requests.get(f'{DOMAIN}{link}')
    bytes = io.BytesIO(response.content)
    with zipfile.ZipFile(bytes, 'r') as zip_ref:
        return [zip_ref.read(file) for file in zip_ref.namelist()]

def unzip_half_hours(week):
    half_hour_csvs = []
    for byteobj in week:
        zf = io.BytesIO(byteobj)
        with zipfile.ZipFile(zf, 'r') as zip_ref:
            half_hour = zip_ref.namelist()[0] # one csv per half-hour zip
            text = zip_ref.read(half_hour).decode()
            half_hour_csvs += text.splitlines()[1:-2] # rm extra context lines 
    return half_hour_csvs   

if __name__ == '__main__':
    week_links = parse_index(INDEX_URL)

    weeks = [unzip_week(week) for week in week_links]

    half_hour_csvs = [unzip_half_hours(week) for week in weeks]
    #print(len(week_bytes))
    #with open('test.csv', 'w') as outfile: