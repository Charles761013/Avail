#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

# 脚本保存路径
SCRIPT_PATH="$HOME/Avail-one.sh"

# 自动设置快捷键的功能
function check_and_set_alias() {
    local alias_name="availf"
    local shell_rc="$HOME/.bashrc"

    # 对于Zsh用户，使用.zshrc
    if [ -n "$ZSH_VERSION" ]; then
        shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_rc="$HOME/.bashrc"
    fi

    # 检查快捷键是否已经设置
    if ! grep -q "$alias_name" "$shell_rc"; then
        echo "设置快捷键 '$alias_name' 到 $shell_rc"
        echo "alias $alias_name='bash $SCRIPT_PATH'" >> "$shell_rc"
        # 添加提醒用户激活快捷键的信息
        echo "快捷键 '$alias_name' 已设置。请运行 'source $shell_rc' 来激活快捷键，或重新打开终端。"
    else
        # 如果快捷键已经设置，提供一个提示信息
        echo "快捷键 '$alias_name' 已经设置在 $shell_rc。"
        echo "如果快捷键不起作用，请尝试运行 'source $shell_rc' 或重新打开终端。"
    fi
}

# 节点安装功能
function install_node() {

# 函数：检查命令是否存在
exists() {
  command -v "$1" >/dev/null 2>&1
}

# 函数：检查依赖项是否存在
exists() {
  command -v "$1" >/dev/null 2>&1
}

# 配置 systemd 服务文件
tee /etc/systemd/system/availd.service > /dev/null << EOF
[Unit]
Description=Avail Light Client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
ExecStart=nohup bash -c 'curl -sL1 avail.sh | bash' > output.log 2>&1 &
Restart=always
RestartSec=60
[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 并启用并启动服务
sudo systemctl daemon-reload
sudo systemctl enable availd
sudo systemctl start availd.service

# 完成安装提示
echo ====================================== 安装完成 =========================================

}



# 查看Avail服务状态
function check_service_status() {
    systemctl status availd
}

# Avail 节点日志查询
function view_logs() {
    sudo journalctl -f -u availd.service 
}

# 查询节点匹配的公钥（建议安装好后，就查询钱包地址，如果日志过长，该功能可能会失效）
function check_wallet() {
    journalctl -u availd | grep "public key"
}

# 主菜单
function main_menu() {
    while true; do
        clear
        echo "脚本以及教程由推特用户大赌哥 @y95277777 编写，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组:https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道:https://t.me/niuwuriji"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装节点"
        echo "2. 查看Avail服务状态"
        echo "3. 节点日志查询"
        echo "4. 查询节点匹配的public key"
        echo "5. 设置快捷键的功能"
        read -p "请输入选项（1-5）: " OPTION

        case $OPTION in
        1) install_node ;;
        2) check_service_status ;;
        3) view_logs ;;
        4) check_wallet ;;
        5) check_and_set_alias ;;
        *) echo "无效选项，请重新输入。" ;;
        esac
        read -p "按任意键返回菜单..." 
    done
}

# 显示主菜单
main_menu