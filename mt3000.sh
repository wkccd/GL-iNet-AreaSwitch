#!/bin/sh
# 免责声明函数
show_disclaimer() {
  clear
  echo "⚠️ 免责声明"
  echo "=============================================="
  echo "使用本脚本可能存在以下风险："
  echo "- 设备无法启动或变砖"
  echo "- 丢失厂商保修"
  echo "- 网络功能异常或配置丢失"
  echo ""
  echo "即使您完全按照教程操作，也可能仍有不可预知的风险。"
  echo "本脚本作者对任何由此产生的问题不承担责任，"
  echo "所有操作风险由用户自行承担。"
  echo "=============================================="
  echo ""
  read -p "您是否同意并愿意继续？(yes/no): " agree
  if [ "$agree" != "yes" ]; then
    echo "您已拒绝免责声明，脚本将退出。"
    exit 1
  fi
}

# 检测型号
check_model() {
    echo "🧰 正在检测路由器型号..."
    local model_file="/proc/gl-hw-info/model"
    local expected_model="mt3000"

    if [ ! -f "$model_file" ]; then
        echo "⚠️ 无法检测型号，文件不存在：$model_file"
        return 1
    fi

    local model
    model=$(cat "$model_file" | tr -d '\r\n')

    if [ "$model" != "$expected_model" ]; then
        echo "❌ 当前设备型号为：$model，非 $expected_model，不支持本脚本操作！"
        return 1
    fi

    echo "✅ 检测到设备型号：$model，符合要求，继续执行..."
    return 0
}

# 获取当前区域函数
get_current_region() {
  region_hex=$(hexdump -C /dev/mtdblock3 | head -n 10 | grep -oE 'US|CN' | head -n 1)
  if [ "$region_hex" = "US" ]; then
    echo "US"
  elif [ "$region_hex" = "CN" ]; then
    echo "CN"
  else
    echo "未知"
  fi
}

# ======================
# 脚本开始执行
# ======================
show_disclaimer  
# 调用检查函数
check_model || exit 1
echo
read -p "按回车键继续..." dummy
# 主循环
while true; do
  clear
  current_region=$(get_current_region)
  echo "========== MT-3000 区域切换工具 ===================="
  echo "当前路由器区域：$current_region"
  echo ""
  echo "1. 切换为美区"
  echo "2. 切换为国区"
  echo "q. 退出"
  echo "==================================================="

  read -p "请输入选项 [1/2/q]: " choice

  case "$choice" in
    1)
      echo ""
      echo "⚠️  警告：切换区域可能会影响保修或部分功能。"
      echo "⚠️  此操作将修改 Flash 并重启路由器。"
      read -p "是否确认切换为美区？(yes/no): " confirm
      if [ "$confirm" = "yes" ]; then
        echo "正在切换为美区..."
        echo -n "US" | dd of=/dev/mtdblock3 bs=1 seek=136 conv=notrunc
        sync
        echo "切换完成，正在重启路由器..."
        sleep 2
        reboot
      else
        echo "已取消操作。"
        sleep 2
      fi
      ;;
    2)
      echo ""
      echo "⚠️  警告：切换区域可能会影响保修或部分功能。"
      echo "⚠️  此操作将修改 Flash 并重启路由器。"
      read -p "是否确认切换为国区？(yes/no): " confirm
      if [ "$confirm" = "yes" ]; then
        echo "正在切换为国区..."
        echo -n "CN" | dd of=/dev/mtdblock3 bs=1 seek=136 conv=notrunc
        sync
        echo "切换完成，正在重启路由器..."
        sleep 2
        reboot
      else
        echo "已取消操作。"
        sleep 2
      fi
      ;;
    q|Q)
      echo "已退出。"
      exit 0
      ;;
    *)
      echo "无效选项，请重新输入。"
      sleep 2
      ;;
  esac
done
