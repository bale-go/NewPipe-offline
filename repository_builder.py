import pandas as pd
import os
import argparse

argParser = argparse.ArgumentParser()
argParser.add_argument("-rc", "--repeat_count", help="the track was streamed at least 'repeat_count' times")
argParser.add_argument("-d", "--duration", help="the track is at most 'duration' seconds long")
args = argParser.parse_args()

streams= pd.read_csv('streams.csv')
streamh= pd.read_csv('stream_history.csv')

top10 = streamh[streamh['repeat_count']>=float(args.repeat_count)]['stream_id']
lista = streams.loc[(streams['uid'].isin(top10))&(streams['duration']<=float(args.duration))]['url'].values.tolist()


for elem in lista:
    os.system("yt-dlp -f bestaudio --audio-quality 0 --audio-format opus -x "+elem)
    
