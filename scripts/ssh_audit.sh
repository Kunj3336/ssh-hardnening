cat << 'EOF' > ~/ssh_audit.sh
#!/usr/bin/env bash
set -u

echo "============================================================"
echo "          SSH SECURITY CONFIGURATION AUDIT REPORT           "
echo "============================================================"
echo "Audit Timestamp : $(date -u)"
echo "Target Hostname : $(hostname)"
echo "Kernel & OS     : $(uname -r) | $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo ""

echo "--- [1] SSH DAEMON SERVICE STATUS ---"
systemctl is-active ssh >/dev/null && echo "SSH Service Status   : ACTIVE" || echo "SSH Service Status   : INACTIVE"
systemctl is-enabled ssh >/dev/null && echo "SSH Service Enabled  : YES" || echo "SSH Service Enabled  : NO"
echo ""

echo "--- [2] LISTENING SOCKETS ---"
ss -tulpn | grep -E ':(22|2222)\b' || echo "No standard SSH port listening"
echo ""

echo "--- [3] EFFECTIVE SSHD CONFIGURATION (sshd -T) ---"
sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|maxauthtries|logingracetime|x11forwarding|allowtcpforwarding|clientaliveinterval|clientalivecountmax|usepam)' | sort
echo ""

echo "--- [4] CONFIGURATION FILE INTEGRITY & PERMISSIONS ---"
ls -ld /etc/ssh/sshd_config
ls -la /etc/ssh/sshd_config.d/ 2>/dev/null || echo "No drop-in directory found"
echo ""

echo "--- [5] HOST FIREWALL STATUS ---"
which ufw >/dev/null && ufw status verbose || echo "UFW not active or installed"
echo "============================================================"
EOF