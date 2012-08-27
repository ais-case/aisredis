
function aisGetResource(resource) {
    $.ajax({
	type:     'GET',
	url:      resource,
	dataType: 'html',
	success:  function(html, textstatus) {
	    $('body').append(html);
	}
    });
    
}
