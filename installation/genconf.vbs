'
' cjdns 設定ファイルの生成とピア情報挿入。
' 設定ファイルは無ければ生成する。
' ピア情報挿入は別のプログラムを呼び出して行う。
' 

dim CJDNS_CONF, PEER_ADD_SCRIPT
' cjdns-設定ファイル
CJDNS_CONF="cjdroute.conf"
' cjdns-設定ファイルにピア情報を挿入するプログラム
PEER_ADD_SCRIPT="add_peers_to_conf.vbs"

Set fso = CreateObject("Scripting.FileSystemObject")

If Not fso.FileExists( CJDNS_CONF ) Then
	' cjdns-設定ファイル の生成
	call_and_wait( "cmd /C ""cjdroute --genconf > " & CJDNS_CONF & " "" " )
End If

If fso.FileExists( PEER_ADD_SCRIPT ) Then
	call_and_wait( "cscript " & PEER_ADD_SCRIPT )
End If

' 関数：プログラムを実行し終了を待つ
Function call_and_wait( cmdline )
	Dim wsh, proc
	Set wsh = CreateObject("WScript.Shell")
	Set proc = wsh.Exec( cmdline )
	Do While proc.Status = 0
		WScript.Sleep 100
	Loop
End Function

