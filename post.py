import os
import requests
from requests_oauthlib import OAuth1

#
# 認証情報
#
CONSUMER_KEY = os.environ["CONSUMER_KEY"]
CONSUMER_SECRET = os.environ["CONSUMER_SECRET"]
ACCESS_TOKEN = os.environ["ACCESS_TOKEN"]
ACCESS_TOKEN_SECRET = os.environ["ACCESS_TOKEN_SECRET"]
XPOST_TITLE = os.environ["XPOST_TITLE"]

auth = OAuth1(
    CONSUMER_KEY,
    CONSUMER_SECRET,
    ACCESS_TOKEN,
    ACCESS_TOKEN_SECRET
)

#
# 画像アップロード
#
def upload_image(filename):
    upload_url = "https://upload.twitter.com/1.1/media/upload.json"

    with open(filename, "rb") as f:
        response = requests.post(
            upload_url,
            auth=auth,
            files={"media": f}
        )

    print(response.status_code)
    print(response.text)

    response.raise_for_status()

    return response.json()["media_id_string"]

#
# 画像をアップロード
#
media_ids = [
    upload_image("surface.png"),
    upload_image("upper.png")
]

#
# 投稿
#
tweet_url = "https://api.twitter.com/2/tweets"

payload = {
    "text": XPOST_TITLE,
    "media": {
        "media_ids": media_ids
    }
}

response = requests.post(
    tweet_url,
    auth=auth,
    json=payload
)

print(response.status_code)
print(response.text)

response.raise_for_status()
