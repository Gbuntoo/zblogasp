<%
'****************************************
' AdvancedNavbar 子菜单
'****************************************
Function AdvancedNavbar_SubMenu(id)
	Dim aryName,aryPath,aryFloat,aryInNewWindow,i
	aryName=Array("导航管理","插件说明","主题&插件接入管理")
	aryPath=Array("main.asp","about.asp","themein.asp")
	aryFloat=Array("m-left","m-right","m-right")
	aryInNewWindow=Array(False,False,False)
	For i=0 To Ubound(aryName)
		AdvancedNavbar_SubMenu=AdvancedNavbar_SubMenu & MakeSubMenu(aryName(i),aryPath(i),aryFloat(i)&IIf(i=id," m-now",""),aryInNewWindow(i))
	Next
End Function

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


'Call RsFilter(数量,提取内容,表名,筛选特性,排列方式,输入框名)
'数据库提取-------------------------------------
Function RsFilter(LTamount,LTList,LType)
	dim LTRS,InserNewHtml:InserNewHtml = ""
	Set LTRS=objConn.Execute("select "&LTamount&" from "&LTList&" where log_Type="&LType&"")
	Do Until LTRS.Eof
		InserNewHtml = InserNewHtml & "<option value="""&LTRS("log_FullUrl")&""">" & LTRS("log_Title") & "</option>"
		LTRS.MoveNext
	Loop
	
	Dim objConfig,ZC_BLOG_HOST
	Set objConfig=New TConfig
	objConfig.Load("Blog")
	ZC_BLOG_HOST=objConfig.Read("ZC_BLOG_HOST")
	InserNewHtml=Replace(InserNewHtml,"<#ZC_BLOG_HOST#>",ZC_BLOG_HOST)
	
	RsFilter = InserNewHtml
	Set LTRS=Nothing
End Function

'Call RrsFilter(数量,提取内容,表名,筛选特性,排列方式,输入框名)
'数据库提取-------------------------------------
Function RrsFilter(LTamount,LTList)
	dim LTRS,InserNewHtml:InserNewHtml = ""
	Set LTRS=objConn.Execute("select "&LTamount&" from "&LTList&"")
	
	Dim objConfig,ZC_BLOG_HOST,ZC_CATEGORY_REGEX,ZC_TAGS_REGEX
	Set objConfig=New TConfig
	objConfig.Load("Blog")
	ZC_BLOG_HOST=objConfig.Read("ZC_BLOG_HOST")
	ZC_CATEGORY_REGEX=objConfig.Read("ZC_CATEGORY_REGEX")
	ZC_TAGS_REGEX=objConfig.Read("ZC_TAGS_REGEX")
	
	ZC_CATEGORY_REGEX=Replace(ZC_CATEGORY_REGEX,"{%host%}/",ZC_BLOG_HOST)
	ZC_TAGS_REGEX=Replace(ZC_TAGS_REGEX,"{%host%}/",ZC_BLOG_HOST)
	ZC_CATEGORY_REGEX=Replace(ZC_CATEGORY_REGEX,"{%id%}","")
	ZC_TAGS_REGEX=Replace(ZC_TAGS_REGEX,"{%alias%}","")
	
	Do Until LTRS.Eof
		if LTList = "blog_Category" then
			InserNewHtml = InserNewHtml & "<option value="""&ZC_CATEGORY_REGEX&LTRS("urlNum")&""">" & LTRS("cate_Name") & "</option>"
		elseif LTList = "blog_Tag" then
			InserNewHtml = InserNewHtml & "<option value="""&ZC_TAGS_REGEX&LTRS("tag_Name")&""">" & LTRS("tag_Name") & "</option>"
		end if
		LTRS.MoveNext
	Loop
	RrsFilter = InserNewHtml
	Set LTRS=Nothing
End Function


Function GetContent(Types)
	Dim TypeContent
	Select Case Types
		Case "Post"	'文章
		TypeContent=RsFilter("log_Title,log_FullUrl","blog_Article","0")
		Case "Page"	'页面
		TypeContent=RsFilter("log_Title,log_FullUrl","blog_Article","1")
		Case "Category"	'分类
		TypeContent=RrsFilter("cate_ID AS urlNum,cate_Name","blog_Category")
		Case "Tags"	'标签
		TypeContent=RrsFilter("tag_Name","blog_Tag")
	End Select
	GetContent= TypeContent
End Function
%>