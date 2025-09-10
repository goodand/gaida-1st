# main.py #telegram_chatbot


'''
[pip install fastapi]로 fastapi 라이브러리 설치 후 진행
[pip install uvicorn[standard]]
터미널에서 실행

이후 아래 터미널 명령어로 서버 켬
uvicorn main:app --reload # app자체가 우리 서버 이름이다.

import requests [파이썬 파일이 많아서 커널 버전 확인 했어야 함]
'''


from fastapi import FastAPI, Request
import random
import requests
import os
from dotenv import load_dotenv
from openai import OpenAI


# .env 파일에 내용들을 불러옴
load_dotenv()


app = FastAPI() # app자체가 우리 서버 이름이다. # 파이썬에서는 파일을 파일이라고 부르지 않고 모듈이라고 부른다.
# 요청을 할 때 가장 많이 쓰는 프로그램 브라우저를 엽니다.
# @app.get('/hi') # hi는 텔레그램의 getMe에 대응해서 생각하면 
# def hi():
#     return{'status':'ok'}


# @app.get('/')
# def home():
#     return{'home':'sweethome'}

def send_message(chat_id, message):
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN') 
    URL = f'https://api.telegram.org/bot{bot_token}'
    body = {
    'chat_id' : chat_id, # 챗 보낸 사람의 id # 인자라서 다름 
    'text' : message 
    }
    requests.get(URL +'/sendMessage',body).json()

    
    # // 알트 키 누른 다음에



# /telegram 라우팅으로 텔레그램 서버가 Bot에 업데이트가 있을 경우, 우리에게 알려줌
@app.post('/telegram')
async def telegram(request:Request):
    print('텔레그램에서 요청이 들어왔다!!!')

    data = await request.json()
    sender_id = data['message']['chat']['id']
    input_msg = data['message']['text']
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

    res = client.responses.create(
        model='gpt-4.1-mini',
        input=input_msg,
        instructions='너는 Dandadan 여주인공*아야세 모모(綾瀬モモ)야',
        temperature=0.3,
        
    )

    #봇에게 답장하다!
    send_message(sender_id,res.output_text)

    return {'status': 'good'}

    

# @app.get('/lotto')
# def lotto():
#     return {
#         'numbers' : random.sample(range(1,46),6)
#     }


# 에러
# ERROR:    Error loading ASGI app. Attribute "app" not found in module "main".