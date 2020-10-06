FROM ubuntu:18.04

#
# 以下為我們自行準備的安裝作業
#

# 設定使用本公司 HTTP Proxy 與 Internet 相連
ENV http_proxy=http://proxy.cht.com.tw:8080
ENV https_proxy=http://proxy.cht.com.tw:8080

ENV USER=root

# 更新 Ubuntu 安裝套件來源網站位置
RUN apt update

# 安裝基本工具
RUN apt install -y wget curl unzip openssh-client

# 安裝 python 與 pip
RUN apt install -y python python-pip

# 安裝可以執行在 container 內的 x-window 環境，與 Firefox 瀏覽器
RUN apt install -y lxde-session
RUN apt install -y firefox

# 設定 VNC Server 執行環境
RUN apt install -y tightvncserver
RUN mkdir -p /root/.vnc
RUN chmod 700 /root/.vnc
COPY ./vnc-passwd /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd
COPY ./vnc-xstartup /root/.vnc/xstartup
RUN chmod +x /root/.vnc/xstartup

# 安裝 selenium
RUN pip install selenium

# 下載支援 Firefox 的 selenium WebDriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz
RUN tar zxf geckodriver-v0.27.0-linux64.tar.gz
RUN mv geckodriver /usr/local/bin
RUN rm geckodriver-v0.27.0-linux64.tar.gz

# 將可以免密碼使用 ssh 指令操作的 private key 複製至此 container 中
RUN mkdir -p /root/.ssh
RUN chmod 700 /root/.ssh
COPY ./id_rsa /root/.ssh
RUN chmod 600 /root/.ssh/id_rsa



#
# 以下為微軟 self-hosted agent 組態設定
#

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl4 \
        libicu60 \
        libunwind8 \
        netcat \
        libssl1.0

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]

