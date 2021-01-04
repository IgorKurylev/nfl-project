import pandas as pd
import plotly.express as px
import time


def animated_slice(df):
    fig = px.scatter(
        df,
        x='x', y='y', color='team', text='position', animation_frame='time', animation_group='position',
        range_x=[-10, 110], range_y=[-10, 60],
        hover_data=['displayName', 'jerseyNumber', 's', 'a', 'dis', 'o', 'playDirection', 'playId'])
    fig.update_traces(textposition='top center', marker_size=10)
    fig.update_layout(paper_bgcolor='darkgreen', plot_bgcolor='darkgreen', font_color='white')

    return fig


if __name__ == '__main__':
    df = pd.read_csv('D:\\DS\\project\\nfl-big-data-bowl-2021\\week1.csv')
    times = df.time.unique()
    single = df.query("playId == 75")

    fig = animated_slice(single)
    #time.sleep(5)
    fig.show()
