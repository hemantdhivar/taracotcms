(function($) {
	$.jmessage = function(header, message, lifetime, class_name) 
	{
		var stack_box = $('#jm_stack_box');
		if(!$(stack_box).length)
		{
			stack_box = $('<div id="jm_stack_box"></div>').prependTo(document.body);
		}
		var message_box = $('<div class="jm_message ' + class_name + '"><h3>' + header + '</h3>' + message + '</div>');
		$(message_box).css('opacity', 0).appendTo('#jm_stack_box').animate({opacity: 1}, 300);
		$(message_box).click(function()
		{
			$(this).animate({opacity: 0}, 300, function()
			{
				$(this).remove();
			});
		});
		if((lifetime = parseInt(lifetime)) > 0)
		{	
			setTimeout(function()
			{
				$(message_box).animate({opacity: 0}, 300, function()
				{
					$(this).remove();
				});
			}, 
			lifetime);
		}
	};
})(jQuery); 
