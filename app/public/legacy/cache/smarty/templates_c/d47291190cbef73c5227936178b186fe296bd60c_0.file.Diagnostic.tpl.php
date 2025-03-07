<?php
/* Smarty version 4.5.3, created on 2025-02-20 04:10:17
  from '/var/www/html/public/legacy/modules/Administration/Diagnostic.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '4.5.3',
  'unifunc' => 'content_67b6ab297f4d08_88727451',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    'd47291190cbef73c5227936178b186fe296bd60c' => 
    array (
      0 => '/var/www/html/public/legacy/modules/Administration/Diagnostic.tpl',
      1 => 1738223969,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_67b6ab297f4d08_88727451 (Smarty_Internal_Template $_smarty_tpl) {
?>
<form name="Diagnostic" method="GET" action="index.php">
<input type="hidden" name="module" value="Administration">
<input type="hidden" name="action" value="DiagnosticRun">

<table cellpadding="0" cellspacing="0" border="0" width="100%" class="actionsContainer">
	<tr>
	<td class="action-button">
	<input title="<?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAG_EXECUTE_BUTTON'];?>
" class="button" onclick="this.form.action.value='DiagnosticRun';" type="submit" name="button" value="  <?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAG_EXECUTE_BUTTON'];?>
  " >
		<input title="<?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAG_CANCEL_BUTTON'];?>
" class="button" onclick="this.form.action.value='index'; this.form.module.value='Administration'; this.form.submit();" type="button" name="button" value="  <?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAG_CANCEL_BUTTON'];?>
">

	</tr>
</table>
<div id="table" style="visibility:visible">
<table id="maintable" width="430" border="0" cellspacing="0" cellpadding="0" class="edit view">
<tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_CONFIGPHP'];?>
</span></td>
	<td ><span><input name='configphp' class="checkbox" type="checkbox" tabindex='1'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_CUSTOMDIR'];?>
</span></td>
	<td ><span><input name='custom_dir' class="checkbox" type="checkbox" tabindex='2'></span></td>
	</tr><tr>

	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_PHPINFO'];?>
</span></td>
	<td ><span><input name='phpinfo' class="checkbox" type="checkbox" tabindex='3'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['DB_NAME']->value;?>
 - <?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_MYSQLDUMPS'];?>
</span></td>
	<td ><span><input name='mysql_dumps' class="checkbox" type="checkbox" tabindex='4'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['DB_NAME']->value;?>
 - <?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_MYSQLSCHEMA'];?>
</span></td>

	<td ><span><input name='mysql_schema' class="checkbox" type="checkbox" tabindex='5'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['DB_NAME']->value;?>
 - <?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_MYSQLINFO'];?>
</span></td>
	<td ><span><input name='mysql_info' class="checkbox" type="checkbox" tabindex='6'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_MD5'];?>
</span></td>
	<td ><span><input name='md5' class="checkbox" type="checkbox" tabindex='7' onclick="md5checkboxes()"></span></td>
	</tr><tr>

	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_FILESMD5'];?>
</span></td>
	<td ><span><input name='md5filesmd5' class="checkbox" type="checkbox" tabindex='8'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_CALCMD5'];?>
</span></td>
	<td ><span><input name='md5calculated' class="checkbox" type="checkbox" tabindex='9'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_BLBF'];?>
</span></td>

	<td ><span><input name='beanlistbeanfiles' class="checkbox" type="checkbox" tabindex='10'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_SUITELOG'];?>
</span></td>
	<td ><span><input name='sugarlog' class="checkbox" type="checkbox" tabindex='11'></span></td>
	</tr><tr>
	<td scope="row"><span><?php echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_DIAGNOSTIC_VARDEFS'];?>
</span></td>
	<td ><span><input name='vardefs' class="checkbox" type="checkbox" tabindex='11'></span></td>
	</tr>
</table>
</div>
</form>


<?php echo '<script'; ?>
 type="text/javascript" language="Javascript">
  var md5filesmd5_checked;
  var md5calculated_checked;
  function show(id) {
      document.getElementById(id).style.display="block";
  }
  function md5checkboxes(){
    if (document.Diagnostic.md5.checked == false){
      md5filesmd5_checked = document.Diagnostic.md5filesmd5.checked;
      md5calculated_checked = document.Diagnostic.md5calculated.checked;
      document.Diagnostic.md5filesmd5.checked=false;
      document.Diagnostic.md5calculated.checked=false;
      document.Diagnostic.md5filesmd5.disabled=true;
      document.Diagnostic.md5calculated.disabled=true;
    }
    else{
      document.Diagnostic.md5filesmd5.disabled=false;
      document.Diagnostic.md5calculated.disabled=false;
      document.Diagnostic.md5filesmd5.checked=md5filesmd5_checked;
      document.Diagnostic.md5calculated.checked=md5calculated_checked;
    }
  }
<?php echo '</script'; ?>
>

<?php }
}
