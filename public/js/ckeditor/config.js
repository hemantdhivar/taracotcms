/*
Copyright (c) 2003-2010, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	config.resize_enabled = false;
	config.height='284px';
  config.skin='BootstrapCK-Skin';
  
  config.smiley_images=['smiley.png','sad.png','wink.png','teeth.png','grin.png','surprised.png','tongue.png','waii.png','evilgrin.png','lightbulb.png','thumbs_down.png','thumbs_up.png','heart.png','envelope.png'];
  config.smiley_descriptions=['smiley','sad','wink','laugh','laugh','suprise','cheecky','grin','evilgrin','lightbulb','thumbs down','thumbs up','heart','mail'];
	
	config.toolbar = 'Taracot';

  config.toolbar_Taracot =
  [
    ['Source','-','NewPage','-','Templates','-','Cut','Copy','Paste','PasteText','PasteFromWord','-','Print','-','BidiLtr', 'BidiRtl'],
    ['Undo','Redo','-','Find','Replace','-','SelectAll','RemoveFormat'],
    ['Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField'],['Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak'],
    '/',
    ['Bold','Italic','Underline','Strike','-','Subscript','Superscript'],
    ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote','CreateDiv'],
    ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
    ['Link','Unlink','Anchor'],
    ['Styles','Format','Font','FontSize'],
    ['TextColor','BGColor'],
    ['Maximize', 'ShowBlocks']
  ];
	
};
