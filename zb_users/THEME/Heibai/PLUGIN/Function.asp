<%
'检验数据是否存在------------------------------------
Function CheckFields(ParameterName,FieldsName,TableName)
	dim cRs
	Set cRs=objConn.Execute("SELECT * FROM "&TableName&" Where "&ParameterName&" like '%" & FieldsName & "%'")
	if not cRs.eof then
		CheckFields = cRs("fn_ID")
		else
		CheckFields = 0
	end if
	Set cRs = nothing
End Function


'Call RsFilter(数量,是否提取图片,提取内容,表名,筛选特性,排列方式,输入框名)
'数据库提取-------------------------------------
Function RsFilter(LTamount,LTImg,LTFilter,LTList,LTWhere,LTType,Lt_textarea,LTSet)
	dim LTRS,InserNewHtml:InserNewHtml = ""
	Set LTRS=objConn.Execute("select top "&LTamount&" "&LTFilter&" from "&LTList&" WHERE "&LTWhere&" order by "&LTType&"")
	Do Until LTRS.Eof
		InserNewHtml = InserNewHtml & "<li><a href="""&LTRS("log_FullUrl")&""" rel=""bookmark"" Title=""" 
		
		if LTSet = "NewArt" then
			InserNewHtml = InserNewHtml & LTRS("log_Title") &""">"
		elseif LTSet = "CommArt" then
			InserNewHtml = InserNewHtml & LTRS("log_Title") & "(" & LTRS("log_CommNums") & "条评论)"">"
		elseif LTSet = "RandomArt" then
			InserNewHtml = InserNewHtml & "详细阅读" & LTRS("log_Title") &""">"
		end if

		InserNewHtml = InserNewHtml & LTRS("log_Title") & "</a></li>"
	
		LTRS.MoveNext
	Loop
	RsFilter = InserNewHtml
	Set LTRS=Nothing
End Function

'评论数据库提取(数量,是否提取图片,提取内容,表名,筛选特性,排列方式,输入框名)-----------
Function RsCommFilter(LTamount,LTImg,LTFilter,LTList,LTWhere,LTType,Lt_textarea)
	dim LTRS,ComRS,InserNewHtml:InserNewHtml = ""
	Set ComRS=objConn.Execute("select top "&LTamount&" "&LTFilter&" from "&LTList&" WHERE "&LTWhere&" order by "&LTType&"")
	Do Until ComRS.Eof
	
	If ComRS("log_ID") <> 0 Then
		Set LTRS=objConn.Execute("select [log_ID],[log_Title],[log_Content],[log_FullUrl] from blog_Article WHERE [log_ID]="&ComRS("log_ID")&" order by Log_PostTime DESC")
		
		InserNewHtml = InserNewHtml & "<li><img src='http://www.gravatar.com/avatar/" & MD5(ComRS("comm_Email")) & "' class='comm_avatar'/>" & ComRS("comm_Author") &":<br /><a href='"&LTRS("log_FullUrl") &"#cmt"& ComRS("comm_ID") & "' title='查看 " & LTRS("log_Title") & "'>" & ComRS("comm_Content") &" </a></li>"
	End if

	ComRS.MoveNext
	Loop
	RsCommFilter = InserNewHtml
	Set LTRS=Nothing
	Set ComRS=Nothing
End Function
'"SELECT TOP 5 comm_Email, comm_HomePage, comm_Author, Count(*) AS comm_Sum FROM blog_Comment GROUP BY comm_Email, comm_HomePage, comm_Author ORDER BY Count(*) DESC;"
'读者墙提取(数量,是否提取图片,提取内容,表名,筛选特性,排列方式,输入框名)-----------
Function RsCommWallFilter(LTamount,LTImg,LTFilter,LTList,LTWhere,LTType,Lt_textarea)
	dim ComWallRS,InserNewHtml:InserNewHtml = ""
	Set ComWallRS=objConn.Execute("SELECT TOP "&LTamount&" "&LTFilter&" FROM "&LTList&" GROUP BY comm_Email, comm_HomePage, comm_Author ORDER BY "&LTType&";")
	Do Until ComWallRS.Eof
		InserNewHtml = InserNewHtml & "<li class=""mostactive""><a href=""" & ComWallRS("comm_HomePage") &""" title=""" & ComWallRS("comm_Author") &" (留下" & ComWallRS("comm_Sum") &"个脚印)"" target=""_blank"" rel=""external nofollow""><img src=""http://www.gravatar.com/avatar/" & MD5(ComWallRS("comm_Email")) & """ alt=""" & ComWallRS("comm_Author") &" (留下" & ComWallRS("comm_Sum") &"个脚印)"" class=""avatar""  /></a></li>"
	ComWallRS.MoveNext
	Loop
	RsCommWallFilter = InserNewHtml
	Set ComWallRS=Nothing
End Function



'检查最新文章列表====================================
Function CheckNewArticle()
	Dim objFunction,objConfig
	Set objConfig=New TConfig
	objConfig.Load("Heibai")
	if FunctionMetas.GetValue("HeibaiNewArtFile")=Empty Then
		Set objFunction=New TFunction
		objFunction.ID=0
		objFunction.Name="最新文章"
		objFunction.FileName="HeibaiNewArtFile"
		objFunction.HtmlID="divNewArt"
		objFunction.Ftype="ul"
		objFunction.Order=15
		objFunction.MaxLi=0
		objFunction.SidebarID=10000
	Else
		Set objFunction=Functions(FunctionMetas.GetValue("HeibaiNewArtFile"))
	End If
	objFunction.IsSystem=True
	objFunction.Content=RsFilter(objConfig.Read("SetNewArt"),True,"*","blog_Article","[log_Type]=0","Log_PostTime DESC","inpContent","NewArt")
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	Set objFunction=Nothing
	Set objConfig=Nothing
End Function

'检查热议列表(评论最高)====================================
Function CheckCommArticle()
	Dim objFunction,objConfig
	Set objConfig=New TConfig
	objConfig.Load("Heibai")
	if FunctionMetas.GetValue("HeibaiCommArtFile")=Empty Then
		Set objFunction=New TFunction
		objFunction.ID=0
		objFunction.Name="热评文章"
		objFunction.FileName="HeibaiCommArtFile"
		objFunction.HtmlID="divCommArt"
		objFunction.Ftype="ul"
		objFunction.Order=16
		objFunction.MaxLi=0
		objFunction.SidebarID=10000
	Else
		Set objFunction=Functions(FunctionMetas.GetValue("HeibaiCommArtFile"))
	End if
	objFunction.IsSystem=True
	objFunction.Content=RsFilter(objConfig.Read("SetCommArt"),True,"*","blog_Article","[log_Type]=0","log_CommNums DESC,Log_PostTime DESC","inpContent","CommArt")
	objFunction.save
	Set objFunction=Nothing
	Set objConfig=Nothing
	'Call MakeBlogReBuild_Core()
	Set objConfig=Nothing
End Function


'检查最新评论列表=============================================
Function CheckNewComm()
	Dim objFunction,objConfig
	Set objConfig=New TConfig
	objConfig.Load("Heibai")
	if FunctionMetas.GetValue("HeibaiNewCommFile")=Empty Then
		Set objFunction=New TFunction
		objFunction.ID=0
		objFunction.Name="最新评论（带头像）"
		objFunction.FileName="HeibaiNewCommFile"
		objFunction.HtmlID="divNewComm"
		objFunction.Ftype="ul"
		objFunction.Order=17
		objFunction.MaxLi=0
		objFunction.SidebarID=10000
	Else
		Set objFunction=Functions(FunctionMetas.GetValue("HeibaiNewCommFile"))
	End if
	objFunction.IsSystem=True
	objFunction.Content=RsCommFilter(objConfig.Read("SetNewComm"),True,"[comm_ID],[log_ID],[comm_HomePage],[comm_Author],[comm_Content],[comm_Email],[comm_PostTime]","blog_Comment","[comm_ID]>0","comm_PostTime DESC","inpContent")
	objFunction.save
	'Call SaveFunctionType()
	Set objFunction=Nothing
	Set objConfig=Nothing
	'Call MakeBlogReBuild_Core()
End Function


'检查读者墙列表=============================================
Function CheckHotCommer()
Dim objFunction,objConfig
Set objConfig=New TConfig
objConfig.Load("Heibai")
if FunctionMetas.GetValue("HeibaiHotCommerfile")=Empty Then
	Set objFunction=New TFunction
	objFunction.ID=0
	objFunction.Name="读者墙"
	objFunction.FileName="HeibaiHotCommerfile"
	objFunction.HtmlID="divHotCommer"
	objFunction.Ftype="ul"
	objFunction.Order=18
	objFunction.MaxLi=0
	objFunction.SidebarID=10000
Else
	Set objFunction=Functions(FunctionMetas.GetValue("HeibaiHotCommerfile"))
End if
	objFunction.IsSystem=True
	objFunction.Content=RsCommWallFilter(objConfig.Read("SetHotCommer"),True,"comm_Email, comm_HomePage, comm_Author, Count(*) AS comm_Sum","blog_Comment","(comm_Email)<>''","Count(*) DESC","inpContent")
	objFunction.save
	'Call SaveFunctionType()

	Set objFunction=Nothing
	Set objConfig=Nothing
	'Call MakeBlogReBuild_Core()
End Function


'检查随机文章列表====================================
Function CheckRandomArticle()
	Dim objFunction,objConfig,Randomval,SortBy
	'randomize
	Randomval = int(rnd * 8)
	Select Case Randomval
		Case 0	'默认
		SortBy = "log_ID DESC"
		Case 1	'发布时间
		SortBy = "Log_PostTime DESC"
		Case 2	'分类方式
		SortBy = "log_CateID DESC"
		Case 3	'别名排序
		SortBy = "log_Url DESC"
		Case 4	'标题排序
		SortBy = "log_Title DESC"
		Case 5	'回复排序
		SortBy = "log_CommNums DESC"
		Case 6	'阅读排序
		SortBy = "log_ViewNums DESC"
		Case 7	'TAGS排序
		SortBy = "log_Tag DESC"
		Case 8	'TAGS排序
		SortBy = "log_Tag DESC"
	End Select
	Set objConfig=New TConfig
	objConfig.Load("Heibai")
	
	if FunctionMetas.GetValue("HeibaiRandomArtFile")=Empty Then
		Set objFunction=New TFunction
		objFunction.ID=0
		objFunction.Name="随机文章"
		objFunction.FileName="HeibaiRandomArtFile"
		objFunction.HtmlID="divRandomArt"
		objFunction.Ftype="ul"
		objFunction.Order=19
		objFunction.MaxLi=0
		objFunction.SidebarID=10000
		else
			Set objFunction=Functions(FunctionMetas.GetValue("HeibaiRandomArtFile"))
	End if
		objFunction.IsSystem=True
		objFunction.Content=RsFilter(objConfig.Read("SetRandomArt"),True,"*","blog_Article","[log_Type]=0",SortBy,"inpContent","RandomArt")
		objFunction.save
		'Call SaveFunctionType()
		Set objFunction=Nothing
		Set objConfig=Nothing
		'Call MakeBlogReBuild_Core()
End Function


'/////////////////////======================================================================/////////////////////

'删除最新文章列表====================================
Function RemNewArticle()
Dim objFunction
Set objFunction=New TFunction
Dim i:i=CheckFields("fn_FileName","Heibainewartfile","blog_Function")
if  i Then
	objFunction.LoadInfoByID(i)
	objFunction.IsSystem=False
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	objFunction.Del
End if
Set objFunction = Nothing
End Function

'删除热议列表(评论最高)====================================
Function RemCommArticle()
Dim objFunction
Set objFunction=New TFunction
Dim i:i=CheckFields("fn_FileName","Heibaicommartfile","blog_Function")

if i <> 0 Then
	objFunction.LoadInfoByID(i)
	objFunction.IsSystem=False
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	objFunction.Del
End if
Set objFunction = Nothing
End Function

'删除随机文章(随机文章)====================================
Function RemRandomArticle()
Dim objFunction
Set objFunction=New TFunction
Dim i:i=CheckFields("fn_FileName","Heibairandomartfile","blog_Function")

if i Then
	objFunction.LoadInfoByID(i)
	objFunction.IsSystem=False
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	objFunction.Del
End if
Set objFunction = Nothing
End Function

'删除评论列表====================================
Function RemNewComm()
Dim objFunction
Set objFunction=New TFunction
Dim i:i=CheckFields("fn_FileName","HeibaiNewCommfile","blog_Function")

if i Then
	objFunction.LoadInfoByID(i)
	objFunction.IsSystem=False
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	objFunction.Del
End if
Set objFunction = Nothing
End Function

'删除读者墙列表===========================================
Function RemHotCommer()
Dim objFunction
Set objFunction=New TFunction
Dim i:i=CheckFields("fn_FileName","HeibaiHotCommerfile","blog_Function")

if i Then
	objFunction.LoadInfoByID(i)
	objFunction.IsSystem=False
	objFunction.save
	'Call SaveFunctionType()
	'Call MakeBlogReBuild_Core()
	objFunction.Del
End if
Set objFunction = Nothing
End Function

'删除TAGS列表===========================================
	' Function RemHotGuestbook()
	' Dim objFunction
	' Set objFunction=New TFunction
	' if CheckFields("fn_FileName","Heibaitagsfile","blog_Function") <> 0 Then
		' objFunction.LoadInfoByID(CheckFields("fn_FileName","Heibaitagsfile","blog_Function"))
		' objFunction.IsSystem=False
		' objFunction.save
		' Call SaveFunctionType()
		' Call MakeBlogReBuild_Core()
		' objFunction.Del
	' End if
	' Set objFunction = Nothing
	' End Function

%>