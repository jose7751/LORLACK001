#!/bin/bash
# INSTALADO --- ACTULIZADO EL 12-01-2023 --By @Kalix1
clear && clear
colores="$(pwd)/colores"
rm -rf ${colores}
wget -O ${colores} "https://raw.githubusercontent.com/jose7751/LORLACK001/main/Otros/colores" &>/dev/null
[[ ! -e ${colores} ]] && exit
chmod +x ${colores} &>/dev/null
source ${colores}
CTRL_C() {
  rm -rf ${colores}
  rm -rf /root/LATAM
  exit
}
trap "CTRL_C" INT TERM EXIT
rm $(pwd)/$0 &>/dev/null
#-- VERIFICAR ROOT
if [ $(whoami) != 'root' ]; then
  echo ""
  echo -e "\e[1;31m NECESITAS SER USER ROOT PARA EJECUTAR EL SCRIPT \n\n\e[97m                DIGITE: \e[1;32m sudo su\n"
  exit
fi
os_system() {
  system=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
  distro=$(echo "$system" | awk '{print $1}')

  case $distro in
  Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
  Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
  esac
}
repo() {
  link="https://raw.githubusercontent.com/jose7751/LORLACK001/main/Source-List/$1.list"
  case $1 in
  8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04) wget -O /etc/apt/sources.list ${link} &>/dev/null ;;
  esac
}
## PRIMER PASO DE INSTALACION
install_inicial() {
  clear && clear
  #--VERIFICAR IP MANUAL
  tu_ip() {
    echo ""
    echo -ne "\e[1;96m #Digite tu IP Publica (IPV4): \e[32m" && read IP
    val_ip() {
      local ip=$IP
      local stat=1
      if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
      fi
      return $stat
    }
    if val_ip $IP; then
      echo "$IP" >/root/.ssh/authrized_key.reg
    else
      echo ""
      echo -e "\e[31mLa IP Digitada no es valida, Verifiquela"
      echo ""
      sleep 5s
      fun_ip
    fi
  }
  #CONFIGURAR SSH-ROOT PRINCIPAL AMAZON, GOOGLE
  pass_root() {
    wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/jose7751/LORLACK001/main/Otros/sshd_config >/dev/null 2>&1
    chmod +rwx /etc/ssh/sshd_config
    service ssh restart
    msgi -bar
    echo -ne "\e[1;97m DIGITE NUEVA CONTRASEÑA:  \e[1;31m" && read pass
    (
      echo $pass
      echo $pass
    ) | passwd root 2>/dev/null
    sleep 1s
    msgi -bar
    echo -e "\e[1;94m     CONTRASEÑA AGREGADA O EDITADA CORECTAMENTE"
    echo -e "\e[1;97m TU CONTRASEÑA ROOT AHORA ES: \e[41m $pass \e[0;37m"

  }
  #-- VERIFICAR VERSION
  v1=$(curl -sSL "https://raw.githubusercontent.com/jose7751/LORLACK001/main/Vercion")
  echo "$v1" >/etc/version_instalacion
  v22=$(cat /etc/version_instalacion)
  vesaoSCT="\e[1;31m [ \e[1;32m( $v22 )\e[1;97m\e[1;31m ]"
  #-- CONFIGURACION BASICA
  os_system
  repo "${vercion}"
  msgi -bar2
  echo -e " \e[5m\e[1;100m   =====>> ►►     SCRIPT NICONET    ◄◄ <<=====    \e[1;37m"
  msgi -bar2
  #-- VERIFICAR VERSION
  msgi -ama "   PREPARANDO INSTALACION | VERSION: $vesaoSCT"
  ## PAQUETES-UBUNTU PRINCIPALES
  echo ""
  echo -e "\e[1;97m              🔎OS DE SU DROPLET VPS🔎 "
  echo -e "\e[1;32m                 | $distro $vercion |"
  echo ""
  echo -e "\e[1;97m          ◽️ DESACTIVANDO PASS ALFANUMERICO ◽️ "
  [[ $(dpkg --get-selections | grep -w "libpam-cracklib" | head -1) ]] || barra_intallb "apt-get install libpam-cracklib -y &>/dev/null"
  echo -e '# Modulo Pass Simple
password [success=1 default=ignore] pam_unix.so obscure sha512
password requisite pam_deny.so
password required pam_permit.so' >/etc/pam.d/common-password && chmod +x /etc/pam.d/common-password
  [[ $(dpkg --get-selections | grep -w "libpam-cracklib" | head -1) ]] && barra_intallb "date"
  service ssh restart >/dev/null 2>&1
  echo ""
  msgi -bar2
  fun_ip() {
    TUIP=$(wget -qO- ifconfig.me)
    echo "$TUIP" >/root/.ssh/authrized_key.reg
    echo -e "\e[1;97m ESTA ES TU IP PUBLICA? \e[32m$TUIP"
    msgi -bar2
    echo -ne "\e[1;97m Seleccione  \e[1;31m[\e[1;93m S \e[1;31m/\e[1;93m N \e[1;31m]\e[1;97m: S\e[1;93m" && read tu_ip
    #read -p " Seleccione [ S / N ]: " S
    [[ "$tu_ip" = "n" || "$tu_ip" = "N" ]] && tu_ip
  }
  fun_ip
  msgi -bar2
  echo -e "\e[1;93m             AGREGAR Y EDITAR PASS ROOT\e[1;97m"
  msgi -bar
  echo -e "\e[1;97m CAMBIAR PASS ROOT? \e[32m"
  msgi -bar2
  echo -ne "\e[1;97m Seleccione  \e[1;31m[\e[1;93m S \e[1;31m/\e[1;93m N \e[1;31m]\e[1;97m: N\e[1;93m" && read pass_root
  #read -p " Seleccione [ S / N ]: "N"
  [[ "$pass_root" = "s" || "$pass_root" = "S" ]] && pass_root
  msgi -bar2
  echo -e "\e[1;93m\a\a\a      SE PROCEDERA A INSTALAR LAS ACTULIZACIONES\n PERTINENTES DEL SISTEMA, ESTE PROCESO PUEDE TARDAR\n VARIOS MINUTOS Y PUEDE PEDIR ALGUNAS CONFIRMACIONES \e[0;37m"
  msgi -bar
  read -t 120 -n 1 -rsp $'\e[1;97m           Preciona Enter Para continuar\n'
  clear && clear
  apt update
  apt upgrade -y
  wget -O /usr/bin/install https://raw.githubusercontent.com/jose7751/LORLACK001/main/install.sh &>/dev/null
  chmod +rwx /usr/bin/install
}

time_reboot() {
  clear && clear
  msgi -bar
  echo -e "\e[1;93m     CONTINUARA INSTALACION DESPUES DEL REINICIO"
  echo -e "\e[1;93m         O EJECUTE EL COMANDO: \e[1;92mLATAM -c "
  msgi -bar
  REBOOT_TIMEOUT="$1"
  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  reboot
}

dependencias() {
  rm -rf /root/paknoinstall.log >/dev/null 2>&1
  rm -rf /root/packinstall.log >/dev/null 2>&1
  dpkg --configure -a >/dev/null 2>&1
  apt -f install -y >/dev/null 2>&1
  soft="sudo bsdmainutils zip screen unzip ufw curl python python3 python3-pip openssl cron iptables lsof pv boxes at mlocate gawk bc jq curl npm nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat apache2"

 # for i in $soft; do
  #  if [[ $(dpkg -s "$i" 2>/dev/null | grep "Status:.*installed") || $(rpm -qa 2>/dev/null | grep "$i") ]]; then
   #   echo "$i está instalado." >> /root/packinstall.log
    #else
     # echo "$i" >> /root/paknoinstall.log
    #fi
  #done
  #soft=$(cat /root/paknoinstall.log)
  for i in $soft; do
    paquete="$i"
    echo -e "\e[1;97m        INSTALANDO PAQUETE \e[93m ------ \e[36m $i"
    barra_intall "apt-get install $i -y"
  done
  rm -rf /root/paknoinstall.log >/dev/null 2>&1
  rm -rf /root/packinstall.log >/dev/null 2>&1
}

install_paquetes() {
  clear && clear
  /bin/cp /etc/skel/.bashrc ~/
  #------- BARRA DE ESPERA
  msgi -bar2
  echo -e " \e[5m\e[1;100m   =====>> ►►     MULTI SCRIPT     ◄◄ <<=====    \e[1;37m"
  msgi -bar
  echo -e "   \e[1;41m    -- INSTALACION PAQUETES FALTANTES --    \e[49m"
  msgi -bar
  dependencias
  sed -i "s;Listen 80;Listen 81;g" /etc/apache2/ports.conf >/dev/null 2>&1
  service apache2 restart >/dev/null 2>&1
  [[ $(sudo lsof -i :81) ]] || ESTATUSP=$(echo -e "\e[1;91m      >>>  FALLO DE INSTALACION EN APACHE <<<") &>/dev/null
  [[ $(sudo lsof -i :81) ]] && ESTATUSP=$(echo -e "\e[1;92m          PUERTO APACHE ACTIVO CON EXITO") &>/dev/null
  echo ""
  echo -e "$ESTATUSP"
  echo ""
  echo -e "\e[1;97m        REMOVIENDO PAQUETES OBSOLETOS - \e[1;32m OK"
  apt autoremove -y &>/dev/null
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
  msgi -bar2
  read -t 30 -n 1 -rsp $'\e[1;97m           Preciona Enter Para continuar\n'
}

#SELECTOR DE INSTALACION
while :; do
  case $1 in
  -s | --start)
    install_inicial && install_paquetes
    break
    ;;
  -c | --continue)
    install_paquetes
    break
    ;;
  -m | --menu)
    break
    ;;
  *) exit ;;
  esac
done

#ADMRufus
install_ADMRufu() {
  clear && clear
  msgi -bar2
  #echo -ne "\033[1;97m Digite su slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msgi -bar2
  clear && clear
  mkdir /etc/ADMRufu >/dev/null 2>&1
  cd /etc
  wget https://raw.githubusercontent.com/jose7751/LORLACK001/main/R9/ADMRufu.tar.xz >/dev/null 2>&1
  tar -xf ADMRufu.tar.xz >/dev/null 2>&1
  chmod +x ADMRufu.tar.xz >/dev/null 2>&1
  rm -rf ADMRufu.tar.xz
  cd
  chmod -R 755 /etc/ADMRufu
  ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
  ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
  SCPinstal="$HOME/install"
  rm -rf /usr/bin/menu
  rm -rf /usr/bin/adm
  rm -rf /usr/bin/ADMRufu
  echo "$slogan" >/etc/ADMRufu/tmp/message.txt
  echo "${ADMRufu}/menu" >/usr/bin/menu && chmod +x /usr/bin/menu
  echo "${ADMRufu}/menu" >/usr/bin/adm && chmod +x /usr/bin/adm
  echo "${ADMRufu}/menu" >/usr/bin/ADMRufu && chmod +x /usr/bin/ADMRufu
  [[ -z $(echo $PATH | grep "/usr/games") ]] && echo 'if [[ $(echo $PATH|grep "/usr/games") = "" ]]; then PATH=$PATH:/usr/games; fi' >>/etc/bash.bashrc
  echo '[[ $UID = 0 ]] && screen -dmS up /etc/ADMRufu/chekup.sh' >>/etc/bash.bashrc
  echo 'v=$(cat /etc/ADMRufu/vercion)' >>/etc/bash.bashrc
  echo '[[ -e /etc/ADMRufu/new_vercion ]] && up=$(cat /etc/ADMRufu/new_vercion) || up=$v' >>/etc/bash.bashrc
  echo -e "[[ \$(date '+%s' -d \$up) -gt \$(date '+%s' -d \$(cat /etc/ADMRufu/vercion)) ]] && v2=\"Nueva Vercion disponible: \$v >>> \$up\" || v2=\"Script Vercion: \$v\"" >>/etc/bash.bashrc
  echo '[[ -e "/etc/ADMRufu/tmp/message.txt" ]] && mess1="$(less /etc/ADMRufu/tmp/message.txt)"' >>/etc/bash.bashrc
  echo '[[ -z "$mess1" ]] && mess1="@Rufu99"' >>/etc/bash.bashrc
  echo 'clear && echo -e "\n$(figlet -f big.flf "  NICONET")\n        RESELLER : @HellBoyVps \n\n   Para iniciar NICONET VPS escriba:  menu \n\n   $v2\n\n"|lolcat' >>/etc/bash.bashrc

  update-locale LANG=en_US.UTF-8 LANGUAGE=en
  clear && clear
  msgi -bar2
  echo -e "\e[1;92m             >> INSTALACION COMPLETADA <<" && msgi -bar2
  echo -e "      COMANDO PRINCIPAL PARA ENTRAR AL PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msgi -bar2
}

#MENUS
clear && clear
/bin/cp /etc/skel/.bashrc ~/
/bin/cp /etc/skel/.bashrc /etc/bash.bashrc
msgi -bar2
echo -e " \e[5m\e[1;100m   =====>> ►►  MENU DE INSTALACION  ◄◄ <<=====   \e[1;37m"
msgi -bar2
#-- VERIFICAR VERSION
v1=$(curl -sSL "https://raw.githubusercontent.com/jose7751/LORLACK001/main/Vercion")
echo "$v1" >/etc/version_instalacion
v22=$(cat /etc/version_instalacion)
vesaoSCT="\e[1;31m [ \e[1;32m( $v22 )\e[1;97m\e[1;31m ]"
msgi -ama "   HELLBOY VPS INSTALADO | VERSION: $vesaoSCT"
msgi -bar2
#echo -ne "\e[1;93m [\e[1;32m1\e[1;93m]\e[1;31m >\e[1;97m VPS-MX FINAL OFICIAL..(8.5)  \e[1;31m \e[97m \n"
#echo -ne "\e[1;93m [\e[1;32m2\e[1;93m]\e[1;31m >\e[1;97m JORGEVPS10............(1.3)   \e[1;31m \e[97m \n"
echo -ne "\e[1;93m [\e[1;32m1\e[1;93m]\e[1;31m >\e[1;97m PRESIONE 1 Y ENTER\e[1;31m \e[97m \n"
#echo -ne "\e[1;93m [\e[1;32m4\e[1;93m]\e[1;31m >\e[1;97m ChumoGH...............(5.7u) \e[1;31m 🎁 FREE \e[97m \n"
#echo -ne "\e[1;93m [\e[1;32m5\e[1;93m]\e[1;31m >\e[1;97m LATAM.................(2.0)  \e[1;96m 💎 ACCESO VIP \e[97m \n"
msgi -bar2
#echo -ne "\e[1;93m [\e[1;32m ARCHIVOS Y LINKS TOTALMENTE ABIERTOS Y PUBLICOS \e[1;93m]\e[1;96m\n       https://github.com/jose7751/LORLACK001\e[97m \n"
#msgi -bar2
echo -ne "\e[1;97mElija un script a instalar:\e[32m "
read opcao
case $opcao in
1)
  install_ADMRufu
  ;;
2)
  install_LACASITA
  ;;
3)
  install_ADM
  ;;
4)
  install_Ch
  ;;
5)
  install_lm
  ;;
esac
exit
