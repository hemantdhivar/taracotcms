$(document).ready(function () {
    function initTree() {
        $('#tree_btns').hide();
        $('#ajax_loading').show();
        $("#tree").dynatree({
            rootCollapsible: false,
            persist: false,
            minExpandLevel: 2,
            clickFolderMode: 3,
            autoFocus: false,
            initAjax: {
                url: "/admin/catalog/data/tree",
                data: {                    
                }
            },
            strings: {
                loading: js_lang_tree_loading,
                loadError: js_lang_tree_load_error
            },
            dnd: {
                preventVoidMoves: true,
                onDragStart: function (node) {
                    if (node.getLevel() == 1) {
                        return false;
                    }
                    return true;
                },
                onDragEnter: function (node, sourceNode) {
                    if (node.getLevel() == 1) {
                        if (node.data.sm_root) {
                            return ["over"]
                        } else {
                            return false;
                        }
                    }
                    return ["before", "after", "over"];
                },
                onDrop: function (node, sourceNode, hitMode, ui, draggable) {
                    sourceNode.move(node, hitMode);
                }
            },
            onActivate: function (node) {
                if (node.getLevel() === 1) {
                    $('#node_edit').hide();
                } else {
                    $('#url').val('');
                    $('#node_edit').show();
                    if (node.data.title) {
                        var ls = js_langs.split(',');
                        for (var i=0; i<ls.length; i++) {
                            $('#node_title_'+ls[i]).val(node.data["lang_"+ls[i]]);
                        }
                    }
                    if (node.data.url) {
                        $('#url').val(node.data.url);
                    }
                    $('#node_title').select();
                    $('#node_title').focus();
                }
            },
            onClick: function (node) {
                if (node.getLevel !== 1) {
                    node.deactivate();
                    node.activate();
                }
            },
            onPostInit: function (node) {
                $('#tree_btns').show();
                $('#ajax_loading').hide();
            },
            onFocus: function (node) {
                if (node.getLevel !== 1) {
                    $('#node_title').select();
                    $('#node_title').focus();
                }
            }
        });
    }
    // Init the tree
    initTree();
    // End: init the tree
    $('#tree_btn_add').click(function () {
        var node = $("#tree").dynatree("getActiveNode");
        var arr = js_langs.split(',');        
        var rn = new Date().valueOf();
        if (node !== null) {            
            _nc = node.addChild({
                uid: rn
            });
            for (var i=0; i<arr.length; i++) {
                if (arr[i].length)
                _nc["lang_"+arr[i]] = '';
                $('#node_title_'+arr[i]).val('');
            }
            _nc.url = '';
            node.expand();
            _nc.activate();            
            _nc.setTitle(js_lang_node_untitled);
        } else {
            var node = $("#tree").dynatree("getRoot");
            if (node.countChildren() === 0) {
                _rn = node.addChild({
                    title: "/",
                    sm_root: "true",
                    isFolder: "true",
                    uid: ""
                });
                _nc = _rn.addChild({
                    uid: ""
                });    
                for (var i=0; i<arr.length; i++) {
                if (arr[i].length)
                    _nc["lang_"+arr[i]] = js_lang_node_untitled;
                }            
                _nc.url = '';
                node.expand();                
                _nc.activate();
                _nc.setTitle(js_lang_node_untitled);
            }
        }
    });
    $('#tree_btn_del').click(function () {
        var node = $("#tree").dynatree("getActiveNode");
        if (node === null) {
            return;
        }
        if (node.getLevel() == 1) {
            return;
        }
        if (!confirm(js_lang_tree_node_del_confirm + ":\n\n" + node.data.title)) {
            return false;
        }
        node.remove();
        $('#node_edit').hide();
    });
    $('#node_btn_save').click(function () {
        var node = $("#tree").dynatree("getActiveNode");
        if (node === null) {
            return;
        }
        if (node.getLevel() == 1) {
            return;
        }
        var arr = js_langs.split(',');
        var data_title = '';
        for (var i=0; i<arr.length; i++) {
            node.data["lang_"+arr[i]] = $('#node_title_'+arr[i]).val();
        }
        node.data['url'] = $('#url').val();
        node.setTitle($('#node_title_'+js_current_lang).val());
        $('#node_edit').hide();
    });
    $('#node_btn_cancel').click(function () {
        $('#node_edit').hide();
    });
    $('#tree_btn_serialize').click(function () {
        var tree = $("#tree").dynatree("getTree");
        $('#tree_btns').hide();
        $('#ajax_loading').show();
        $.ajax({
            type: 'POST',
            url: '/admin/catalog/data/tree/save',
            data: {
                data: JSON.stringify(tree.toDict(), null, 2)
            },
            dataType: "json",
            success: function (data) {
                $('#tree_btns').show();
                $('#ajax_loading').hide();
                if (data.result != 1) {
                    $.jmessage(js_lang_error, js_lang_tree_save_error, 2500, 'jm_message_success');
                    return;
                }
                $('#node_edit').hide();
                $.jmessage(js_lang_success, js_lang_tree_save_success, 2500, 'jm_message_success');
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            }
        });
    });    
});