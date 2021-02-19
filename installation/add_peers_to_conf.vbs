'
' cjdroute.conf にピア情報を挿入する。
' 挿入するピア情報が既に cjdroute.conf にあれば何もしない。
'

Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

' ピア情報を挿入する書き換え対象のファイル
source_file = "cjdroute.conf"
' 一時ファイル
temp_file = "cjdroute.tmp"
' 挿入するピア情報のあるファイル
peer_file = "add_peers_list.txt"
' 挿入位置。この行の直後にピア情報を挿入する。
insert_point = "// Ask somebody who is already connected."

'--------------------------------------------------
' 挿入するピア情報が書き換え対象のファイルに無いことをチェックする。
'--------------------------------------------------
dim ret 
If Not fso.FileExists( peer_file ) Then
	' ピア情報ファイルが無い。異常。終了する。
	WScript.Quit 99
End If

If IsFileInAll( peer_file, source_file ) Then
	'WScript.Echo "WARNING : IPv4 addr-port in " & peer_file & " is already exist in " & source_file & "."
	WScript.Quit 1
End If

'--------------------------------------------------
' ピア情報ファイルの挿入処理
'--------------------------------------------------

set in_stream = fso.OpenTextFile(source_file)
' Make a temp file, clobbering any already there
set out_stream = fso.CreateTextFile(temp_file, True)

' We only need to add at the first line, since IPv4 comes before IPv6
need_to_add = True

Do Until in_stream.AtEndOfStream
    ' Copy over config file lines
    line = in_stream.ReadLine
    out_stream.WriteLine line
    
    if InStr(line, insert_point) <> 0 then
        if need_to_add then
            ' This is the first occurrence (IPv4)
            set peer_stream = fso.OpenTextFile(peer_file)
            
            Do Until peer_stream.AtEndOfStream
                ' Copy over all the public peers
                line2 = peer_stream.ReadLine
                out_stream.WriteLine line2
            Loop
            
            need_to_add = False
        end if
    end if
Loop

in_stream.Close
out_stream.Close
peer_stream.Close

fso.DeleteFile source_file
fso.MoveFile temp_file, source_file


' 関数：ファイルの中身にある IPv4アドレス・ポートがもう片方のファイルにあるか。
Function IsFileInAll( peer_file, source_file )
	dim re, mc, mc2
	set re = createObject("VBScript.RegExp")
	' IPv4・ポートのパターン。ただしコメント化されていない。
	re.pattern = "(?!//)""(\d+)\.(\d+)\.(\d+)\.(\d+):(\d+)""\s*:\s*{"
	set in_stream = fso.OpenTextFile(peer_file)
	Do Until in_stream.AtEndOfStream
		line = in_stream.ReadLine
		set mc = re.execute( line )
		if mc.count > 0 then ' マッチした数
'			WScript.Echo "A:" & mc.item(0)
			set in_stream_2 = fso.OpenTextFile(source_file)
			Do Until in_stream_2.AtEndOfStream
				line_2 = in_stream_2.ReadLine
				set mc2 = re.execute(line_2)
				if mc2.count > 0 then 
'					WScript.Echo "B:" & mc.item(0)
					' 行マッチング
					if mc.item(0).submatches.item(0) = mc2.item(0).submatches.item(0) And _
						mc.item(0).submatches.item(1) = mc2.item(0).submatches.item(1) And _
						mc.item(0).submatches.item(2) = mc2.item(0).submatches.item(2) And _
						mc.item(0).submatches.item(3) = mc2.item(0).submatches.item(3) And _
						mc.item(0).submatches.item(4) = mc2.item(0).submatches.item(4) Then
					   	IsFileInAll = True ' マッチした
'						WScript.Echo "match."
				   		Exit Function
			   		End If
				End If
			Loop
		End If
	Loop
	IsFileInAll = False
End Function
