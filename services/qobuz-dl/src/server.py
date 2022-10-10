from fastapi import BackgroundTasks, FastAPI
from fastapi.responses import RedirectResponse
from qobuz_dl.core import QobuzDL
import logging
import requests
import os

logging.basicConfig(level=logging.INFO)

email = os.environ['QOBUZ_EMAIL']
password = os.environ['QOBUZ_PASSWORD']

dl_dir="/app/music/"

app = FastAPI()

def qobuz_download_album(artist, album_id):
    qobuz = QobuzDL(
        directory=dl_dir + artist,
        # directory="/app/downloads",
        quality = 27,
        embed_art = True,
        ignore_singles_eps = False,
        no_m3u_for_playlists = False,
        quality_fallback = True,
        no_cover = False,
        folder_format = "{year} - {album}",
        track_format = "{tracknumber} - {tracktitle}",
        smart_discography = True
    )
    qobuz.get_tokens() # get 'app_id' and 'secrets' attrs
    qobuz.initialize_client(email, password, qobuz.app_id, qobuz.secrets)

    qobuz.handle_url(f"https://play.qobuz.com/album/" + album_id)
    # notifiy_end()
    return

@app.get("/")
async def root():
    return RedirectResponse("/docs")

@app.get("/health")
async def root():
    return

@app.get("/{artist}/{album_id}", status_code=202)
async def download_album(artist, album_id, background_tasks: BackgroundTasks):
    background_tasks.add_task(qobuz_download_album,artist = artist, album_id=album_id)
    # notifiy_start()
    return

def notifiy_start():
    url = "http://192.168.178.100:8525/message/silent"
    data = {
        "title": "qobuz-dl",
        "text": "Download started",
    }
    response = requests.post(url, json=data)

    print("Status Code", response.status_code)

def notifiy_end():
    url = "http://192.168.178.100:8525/message/silent"
    data = {
        "title": "qobuz-dl",
        "text": "Download complete",
    }
    response = requests.post(url, json=data)

    print("Status Code", response.status_code)
