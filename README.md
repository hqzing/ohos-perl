# ohos-perl
本项目为 OpenHarmony 平台编译了 perl，并发布预构建包。

## 获取软件包
前往 [release 页面](https://github.com/Harmonybrew/ohos-perl/releases) 获取。

## 用法
**1\. 在鸿蒙 PC 中使用**

由于当前鸿蒙 PC 还不支持 在 HiShell 里面运行用户目录内的二进制，所以我们不能以“解压 + 配 PATH” 方式使用。你需要把它做成 hnp 包，然后才能在 HiShell 中调用。详情请参考 [Termony
](https://github.com/TermonyHQ/Termony) 的方案。

**2\. 在鸿蒙开发板中使用**

用 hdc 把它推到设备上，然后以“解压 + 配 PATH” 方式使用。

示例：
```sh
hdc file send perl-5.42.0-ohos-arm64.tar.gz /data
hdc shell

cd /data
tar -zxf perl-5.42.0-ohos-arm64.tar.gz
export PATH=$PATH:/data/perl-5.42.0-ohos-arm64/bin

# 现在你可以使用 perl 命令了
```

**3\. 在 [鸿蒙容器](https://github.com/hqzing/docker-mini-openharmony) 中使用**

容器环境内置了 curl，所以我们可以直接在容器中下载这个软件包，然后以“解压 + 配 PATH” 方式使用。

示例：
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker exec -it ohos sh

cd /root
curl -L -O https://github.com/Harmonybrew/ohos-perl/releases/download/5.42.0/perl-5.42.0-ohos-arm64.tar.gz
tar -zxf perl-5.42.0-ohos-arm64.tar.gz -C /opt
export PATH=$PATH:/opt/perl-5.42.0-ohos-arm64/bin

# 现在你可以使用 perl 命令了
```

## 从源码构建

与当前业界普遍采用的交叉编译的做法不同，这个项目使用本地编译（native compilation，也可以叫本机编译或原生编译）的做法来编译 perl。

需要在鸿蒙容器中运行项目里的 build.sh，以实现 perl 的本地编译。

示例：
```sh
git clone https://github.com/Harmonybrew/ohos-perl.git

docker run -itd --name=ohos ghcr.io/hqzing/docker-mini-openharmony:latest
docker cp ohos-perl ohos:/root
docker exec -it ohos sh

cd /root/ohos-perl
./build.sh

# 构建完成后会在容器中生成 /opt/perl-5.42.0-ohos-arm64.tar.gz
```
