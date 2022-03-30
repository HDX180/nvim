# upgrade gcc
yum --enablerepo=tlinux-testing install tlinux-release-gcc-update
yum remove tlinux12-compat compat-gcc-44-c++
yum update gcc

# install cmake
wget https://github.com/Kitware/CMake/releases/download/v3.23.0-rc5/cmake-3.23.0-rc5.tar.gz
tar xvf cmake-3.23.0-rc5.tar.gz
./configure --prefix=/usr/local
make -j8 && make install

# install nodejs
yum install -y nodejs
yum install npm

# install python3
https://www.python.org/downloads/release/python-357/
tar xzf Python-3.5.7.tgz
cd Python-3.5.7
./configure --prefix=/usr/local
make -j8 && make install

# install pip 
yum install python-pip

# 添加nvim的python支持
pip2 install --user --upgrade neovim
pip3 install --user --upgrade neovim

# install nvim
git clone -b release-0.6 https://github.com/neovim/neovim.git
make CMAKE_BUILD_TYPE=Release
make install

# install rg
https://github.com/BurntSushi/ripgrep/releases
tar xvf 
cp rg /usr/local/bin

# install gtags
https://ftp.gnu.org/pub/gnu/global/
tar xvf
./configure
make -j8 && make install

# install clang+llvm
https://github.com/llvm/llvm-project/releases
cd llvm
mkdir build
cd build
cmake ../llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=clang
make -j4
make install

# install ccls
git clone --depth=1 --recursive https://github.com/MaskRay/ccls
cmake . -DCMAKE_CXX_FLAGS=-D__STDC_FORMAT_MACROS
make -j8
make install

# 切换zsh
chsh -s /bin/zsh
#install pure
npm install --global pure-prompt
## .zshrc启用
autoload -U promptinit; promptinit
prompt pure

