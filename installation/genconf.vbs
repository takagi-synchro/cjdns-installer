'
' cjdns �ݒ�t�@�C���̐����ƃs�A���}���B
' �ݒ�t�@�C���͖�����ΐ�������B
' �s�A���}���͕ʂ̃v���O�������Ăяo���čs���B
' 

dim CJDNS_CONF, PEER_ADD_SCRIPT
' cjdns-�ݒ�t�@�C��
CJDNS_CONF="cjdroute.conf"
' cjdns-�ݒ�t�@�C���Ƀs�A����}������v���O����
PEER_ADD_SCRIPT="add_peers_to_conf.vbs"

Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FileExists( CJDNS_CONF ) Then
	' cjdns-�ݒ�t�@�C�� �̐���
	call_and_wait( "cmd /C ""cjdroute --genconf > " & CJDNS_CONF & " "" " )
End If

If fso.FileExists( PEER_ADD_SCRIPT ) Then
	call_and_wait( "cscript " & PEER_ADD_SCRIPT )
End If

' �֐��F�v���O���������s���I����҂�
Function call_and_wait( cmdline )
	Dim wsh, proc
	Set wsh = CreateObject("WScript.Shell")
	Set proc = wsh.Exec( cmdline )
	Do While proc.Status = 0
		WScript.Sleep 100
	Loop
End Function

