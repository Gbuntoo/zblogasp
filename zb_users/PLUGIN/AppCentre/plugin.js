$(document).ready(function(){ 

$("#divMain2").prepend("<form class='search' name='edit' id='edit' method='post' enctype='multipart/form-data' action='"+bloghost+"cmd.asp?act=FileUpload'><p>上传插件zpi文件:&nbsp;<input type='file' id='edtFileLoad' name='edtFileLoad' size='40' />&nbsp;&nbsp;&nbsp;&nbsp;<input type='submit' class='button' value='提交' name='B1' />&nbsp;&nbsp;<input class='button' type='reset' value='重置' name='B2' />&nbsp;</p></form>")


$("tr").each(function(){
	$(this).append("<td width='12%' align='center'></td>");
});

$("tr").first().children().last().append("AppCentre");

$(".plugin").each(function(){
	var t=$(this).find("strong").html();
	var s=""
	s=s+"<a href='"+t+"' title='编辑该插件'><img height='16' width='16' src='"+bloghost+"zb_users/plugin/appcentre/images/application_edit.png'/></a>";
	s=s+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='"+bloghost+"zb_users/plugin/appcentre/plugin_pack.asp?id="+t+"' title='导出该插件' target='_blank'><img height='16' width='16' src='"+bloghost+"zb_users/plugin/appcentre/images/download.png'/></a>";
	s=s+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='"+t+"' title='更新该插件'><img height='16' width='16' src='"+bloghost+"zb_users/plugin/appcentre/images/refresh.png'/></a>";
	if(!$(this).hasClass("plugin-on")){
		$(this).parent().children().last().prev().append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='"+t+"' title='删除该插件'><img height='16' width='16' src='"+bloghost+"zb_users/plugin/appcentre/images/delete.png'/></a>");
	};
	$(this).parent().children().last().append(s);
});



});