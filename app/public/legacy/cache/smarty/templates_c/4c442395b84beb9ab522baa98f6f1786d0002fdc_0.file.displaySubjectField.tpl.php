<?php
/* Smarty version 4.5.3, created on 2025-02-20 04:09:59
  from '/var/www/html/public/legacy/modules/Emails/templates/displaySubjectField.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '4.5.3',
  'unifunc' => 'content_67b6ab174c4811_97660699',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '4c442395b84beb9ab522baa98f6f1786d0002fdc' => 
    array (
      0 => '/var/www/html/public/legacy/modules/Emails/templates/displaySubjectField.tpl',
      1 => 1738223969,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_67b6ab174c4811_97660699 (Smarty_Internal_Template $_smarty_tpl) {
$_smarty_tpl->_checkPlugins(array(0=>array('file'=>'/var/www/html/public/legacy/include/Smarty/plugins/function.convert_link.php','function'=>'smarty_function_convert_link',),));
?>
<div class="email-subject">
    <?php if ($_smarty_tpl->tpl_vars['bean']->value) {?>
                <?php if ($_smarty_tpl->tpl_vars['bean']->value['name'] == '') {?>
            <?php $_smarty_tpl->smarty->ext->_capture->open($_smarty_tpl, 'subject', 'subject', null);
echo $_smarty_tpl->tpl_vars['MOD']->value['LBL_NO_SUBJECT'];
$_smarty_tpl->smarty->ext->_capture->close($_smarty_tpl);?>
        <?php } else { ?>
            <?php $_smarty_tpl->smarty->ext->_capture->open($_smarty_tpl, 'subject', 'subject', null);
echo $_smarty_tpl->tpl_vars['bean']->value['name'];
$_smarty_tpl->smarty->ext->_capture->close($_smarty_tpl);?>
        <?php }?>

                <?php if (!empty($_smarty_tpl->tpl_vars['bean']->value['id']) && $_smarty_tpl->tpl_vars['bean']->value['status'] == $_smarty_tpl->tpl_vars['APP_LIST_STRINGS']->value['dom_email_status']['draft']) {?>
            <?php $_smarty_tpl->_assignInScope('url', "index.php?module=Emails&action=DetailDraftView&record=".((string)$_smarty_tpl->tpl_vars['bean']->value['id']));?>
        <?php } elseif (!empty($_smarty_tpl->tpl_vars['bean']->value['id']) && $_smarty_tpl->tpl_vars['bean']->value['status'] != $_smarty_tpl->tpl_vars['APP_LIST_STRINGS']->value['dom_email_status']['draft']) {?>
            <?php $_smarty_tpl->_assignInScope('url', "index.php?module=Emails&action=DetailView&record=".((string)$_smarty_tpl->tpl_vars['bean']->value['id']));?>
        <?php } elseif (!empty($_smarty_tpl->tpl_vars['bean']->value)) {?>
            <?php ob_start();
if (!empty($_smarty_tpl->tpl_vars['bean']->value['folder'])) {
echo (string)$_smarty_tpl->tpl_vars['bean']->value['folder'];
}
$_prefixVariable1=ob_get_clean();
ob_start();
if (!empty($_smarty_tpl->tpl_vars['bean']->value['folder_type'])) {
echo (string)$_smarty_tpl->tpl_vars['bean']->value['folder_type'];
}
$_prefixVariable2=ob_get_clean();
ob_start();
if (!empty($_smarty_tpl->tpl_vars['bean']->value['inbound_email_record'])) {
echo (string)$_smarty_tpl->tpl_vars['bean']->value['inbound_email_record'];
}
$_prefixVariable3=ob_get_clean();
ob_start();
if (!empty($_smarty_tpl->tpl_vars['bean']->value['uid'])) {
echo (string)$_smarty_tpl->tpl_vars['bean']->value['uid'];
}
$_prefixVariable4=ob_get_clean();
ob_start();
if (!empty($_smarty_tpl->tpl_vars['bean']->value['msgno'])) {
echo (string)$_smarty_tpl->tpl_vars['bean']->value['msgno'];
}
$_prefixVariable5=ob_get_clean();
$_smarty_tpl->_assignInScope('url', "index.php?module=Emails&action=DisplayDetailView&folder_name=".$_prefixVariable1."&folder=".$_prefixVariable2."&inbound_email_record=".$_prefixVariable3."&uid=".$_prefixVariable4."&msgno=".$_prefixVariable5);?>
        <?php }?>

        <a href='<?php echo smarty_function_convert_link(array('link'=>$_smarty_tpl->tpl_vars['url']->value),$_smarty_tpl);?>
'><?php echo $_smarty_tpl->tpl_vars['subject']->value;?>
</a>

    <?php }?>
</div>
<?php }
}
