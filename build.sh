#!/bin/sh
set -e

alpine_repository="http://dl-cdn.alpinelinux.org/alpine/v3.22/main/aarch64/"

download_alpine_index() {
    curl -fsSL ${alpine_repository}/APKINDEX.tar.gz | tar -zx -C /tmp
}

get_apk_url() {
    package_name=$1
    package_version=$(grep -A1 "^P:${package_name}$" /tmp/APKINDEX | sed -n "s/^V://p")
    apk_file_name=${package_name}-${package_version}.apk
    echo ${alpine_repository}/${apk_file_name}
}

# 准备一些杂项的命令行工具
download_alpine_index
curl -L -O $(get_apk_url busybox-static)
curl -L -O $(get_apk_url make)
for file in *.apk; do
  tar -zxf $file -C /
done
rm -rf *.apk
rm /bin/xargs
ln -s /bin/busybox.static /bin/xargs
ln -s /bin/busybox.static /bin/tr
ln -s /bin/busybox.static /bin/expr
ln -s /bin/busybox.static /bin/awk
ln -s /bin/busybox.static /bin/unzip

# 准备 ohos-sdk
# OpenHarmony 发布页（https://gitcode.com/openharmony/docs/blob/master/zh-cn/release-notes/OpenHarmony-v6.0-release.md）里面并没有发布鸿蒙版的 ohos-sdk，只发布了 Windows、Linux、Mac 版本
# 为了进行本地编译，这里只能从 OpenHarmony 官方社区的每日构建流水线（https://ci.openharmony.cn/workbench/cicd/dailybuild/dailylist）下载 OpenHarmony 主干版本编出来的鸿蒙版 ohos-sdk
sdk_ohos_download_url="https://cidownload.openharmony.cn/version/Master_Version/ohos-sdk-public_ohos/20251027_020623/version-Master_Version-ohos-sdk-public_ohos-20251027_020623-ohos-sdk-public_ohos.tar.gz"
curl $sdk_ohos_download_url -o ohos-sdk-public_ohos.tar.gz
mkdir /opt/ohos-sdk
tar -zxf ohos-sdk-public_ohos.tar.gz -C /opt/ohos-sdk
cd /opt/ohos-sdk/ohos/
unzip -q native-*.zip
unzip -q toolchains-*.zip
cd - >/dev/null

# 编译 perl
export PATH=$PATH:/opt/ohos-sdk/ohos/native/llvm/bin
curl -L https://github.com/Perl/perl5/archive/refs/tags/v5.42.0.tar.gz -o perl5-5.42.0.tar.gz
tar -zxf perl5-5.42.0.tar.gz
cd perl5-5.42.0
sed -i 's/defined(__ANDROID__)/defined(__ANDROID__) || defined(__OHOS__)/g' perl_langinfo.h
./Configure \
    -des \
    -Dprefix=/opt/perl-5.42.0-ohos-arm64 \
    -Duserelocatableinc \
    -Dcc=clang \
    -Dcpp=clang++ \
    -Dar=llvm-ar \
    -Dnm=llvm-nm \
    -Accflags=-D_GNU_SOURCE
make -j$(nproc)
make install
cd ..

# 履行开源义务，将 license 随制品一起发布
cp perl5-5.42.0/Copying /opt/perl-5.42.0-ohos-arm64
cp perl5-5.42.0/AUTHORS /opt/perl-5.42.0-ohos-arm64

# 代码签名。做这一步是为了现在或以后能让它运行在 OpenHarmony 的商业发行版——HarmonyOS 上。
export PATH=$PATH:/opt/ohos-sdk/ohos/toolchains/lib
binary-sign-tool sign -inFile /opt/perl-5.42.0-ohos-arm64/bin/perl5.42.0 -outFile /opt/perl-5.42.0-ohos-arm64/bin/perl5.42.0 -selfSign 1
find /opt/perl-5.42.0-ohos-arm64/lib/ -type f | grep -E '\.so(\.[0-9]+)*$' | xargs -I {} binary-sign-tool sign -inFile {} -outFile {} -selfSign 1

# 打包最终产物
cd /opt/
tar -zcf perl-5.42.0-ohos-arm64.tar.gz perl-5.42.0-ohos-arm64
