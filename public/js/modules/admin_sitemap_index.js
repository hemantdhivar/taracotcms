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
                url: "/admin/sitemap/data/tree",
                data: {
                    lang: $('#select_lang').val()
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
                    $('#node_edit').show();
                    if (node.data.title) {
                        $('#node_title').val(node.data.title);
                    }
                    if (node.data.url) {
                        $('#node_url').val(node.data.url);
                    } else {
                        $('#node_url').val('');
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
    $('#tree_btn_load').click(

    function () {
        $("#tree_lang").hide();
        $("#tree_editor").show();
        initTree();
    });
    $('#tree_btn_add').click(

    function () {
        var node = $("#tree").dynatree("getActiveNode");
        if (node !== null) {
            _nc = node.addChild({
                title: js_lang_node_untitled,
                url: ""
            });
            node.expand();
            _nc.activate();
        } else {
            var node = $("#tree").dynatree("getRoot");
            if (node.countChildren() === 0) {
                _rn = node.addChild({
                    title: "/",
                    sm_root: "true",
                    isFolder: "true",
                    url: ""
                });
                _nc = _rn.addChild({
                    title: js_lang_node_untitled,
                    url: ""
                });
                node.expand();
                _nc.activate();
            }
        }
    });
    $('#tree_btn_del').click(

    function () {
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
    $('#node_btn_save').click(

    function () {
        var node = $("#tree").dynatree("getActiveNode");
        if (node === null) {
            return;
        }
        if (node.getLevel() == 1) {
            return;
        }
        node.data.title = $('#node_title').val();
        node.data.url = $('#node_url').val();
        node.setTitle($('#node_title').val());
        $('#node_edit').hide();
    });
    $('#node_btn_cancel').click(

    function () {
        $('#node_edit').hide();
    });
    $('#tree_btn_serialize').click(

    function () {
        var tree = $("#tree").dynatree("getTree");
        $('#tree_btns').hide();
        $('#ajax_loading').show();
        $.ajax({
            type: 'POST',
            url: '/admin/sitemap/data/tree/save',
            data: {
                data: JSON.stringify(tree.toDict(), null, 2),
                lang: $('#select_lang').val()
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
                $("#tree").dynatree("destroy");
                $('#tree_editor').hide();
                $('#tree_lang').show();
                $.jmessage(js_lang_success, js_lang_tree_save_success, 2500, 'jm_message_success');
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            }
        });
    });
    $('#tree_btn_cancel').click(

    function () {
        if (!confirm(js_lang_tree_cancel_confirm)) {
            return false;
        }
        $('#node_edit').hide();
        $("#tree").dynatree("destroy");
        $('#tree_editor').hide();
        $('#tree_lang').show();
    });
    $('#tree_btn_reset').click(

    function () {
        if (!confirm(js_lang_tree_reset_confirm)) {
            return false;
        }
        var node = $("#tree").dynatree("getRoot");
        node.removeChildren();
        node.addChild({
            title: "/",
            sm_root: "true",
            isFolder: "true",
            url: ""
        });
        $('#tree_btns').hide();
        $('#ajax_loading').show();
        $.ajax({
            type: 'POST',
            url: '/admin/sitemap/data/tree/save',
            data: {
                data: JSON.stringify($("#tree").dynatree("getTree").toDict(), null, 2),
                lang: $('#select_lang').val()
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
                $("#tree").dynatree("destroy");
                $('#tree_editor').hide();
                $('#tree_lang').show();
                $.jmessage(js_lang_success, js_lang_tree_save_success, 2500, 'jm_message_success');
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            }
        });
    });
    // Keypress events
    $("#node_title").keypress(function (e) {
        if (e.which == 13) {
            $("#node_btn_save").click();
        }
    });
    $("#node_url").keypress(function (e) {
        if (e.which == 13) {
            $("#node_btn_save").click();
        }
    });
});