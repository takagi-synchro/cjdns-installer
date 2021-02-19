'
' cjdroute.conf �Ƀs�A����}������B
' �}������s�A��񂪊��� cjdroute.conf �ɂ���Ή������Ȃ��B
'

Const ForReading = 1, ForWriting = 2
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the full path to us and our config files
root = fso.GetParentFolderName(WScript.ScriptFullName)

' �s�A����}�����鏑�������Ώۂ̃t�@�C��
source_file = "cjdroute.conf"
' �ꎞ�t�@�C��
temp_file = "cjdroute.tmp"
' �}������s�A���̂���t�@�C��
peer_file = "add_peers_list.txt"
' �}���ʒu�B���̍s�̒���Ƀs�A����}������B
insert_point = "// Ask somebody who is already connected."

'--------------------------------------------------
' �}������s�A��񂪏��������Ώۂ̃t�@�C���ɖ������Ƃ��`�F�b�N����B
'--------------------------------------------------
dim ret 
If Not fso.FileExists( peer_file ) Then
	' �s�A���t�@�C���������B�ُ�B�I������B
	WScript.Quit 99
End If

If IsFileInAll( peer_file, source_file ) Then
	'WScript.Echo "WARNING : IPv4 addr-port in " & peer_file & " is already exist in " & source_file & "."
	WScript.Quit 1
End If

'--------------------------------------------------
' �s�A���t�@�C���̑}������
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


' �֐��F�t�@�C���̒��g�ɂ��� IPv4�A�h���X�E�|�[�g�������Е��̃t�@�C���ɂ��邩�B
Function IsFileInAll( peer_file, source_file )
	dim re, mc, mc2
	set re = createObject("VBScript.RegExp")
	' IPv4�E�|�[�g�̃p�^�[���B�������R�����g������Ă��Ȃ��B
	re.pattern = "(?!//)""(\d+)\.(\d+)\.(\d+)\.(\d+):(\d+)""\s*:\s*{"
	set in_stream = fso.OpenTextFile(peer_file)
	Do Until in_stream.AtEndOfStream
		line = in_stream.ReadLine
		set mc = re.execute( line )
		if mc.count > 0 then ' �}�b�`������
'			WScript.Echo "A:" & mc.item(0)
			set in_stream_2 = fso.OpenTextFile(source_file)
			Do Until in_stream_2.AtEndOfStream
				line_2 = in_stream_2.ReadLine
				set mc2 = re.execute(line_2)
				if mc2.count > 0 then 
'					WScript.Echo "B:" & mc.item(0)
					' �s�}�b�`���O
					if mc.item(0).submatches.item(0) = mc2.item(0).submatches.item(0) And _
						mc.item(0).submatches.item(1) = mc2.item(0).submatches.item(1) And _
						mc.item(0).submatches.item(2) = mc2.item(0).submatches.item(2) And _
						mc.item(0).submatches.item(3) = mc2.item(0).submatches.item(3) And _
						mc.item(0).submatches.item(4) = mc2.item(0).submatches.item(4) Then
					   	IsFileInAll = True ' �}�b�`����
'						WScript.Echo "match."
				   		Exit Function
			   		End If
				End If
			Loop
		End If
	Loop
	IsFileInAll = False
End Function
