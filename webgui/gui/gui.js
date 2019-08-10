
function CreateText(id, top, left, fontsize, text) {

	$(".siteWrapper").append('<span data-id="'+id+'" style="position: fixed; top: '+top+'vh; left: '+left+'vw; font-size: '+fontsize+'vw;">'+text+'</span>');
}

function SetText(id, text) {

	let textlabel = $(".siteWrapper").find("[data-id='"+id+"']");

	textlabel.html(text);
}

function DestroyText(id) {
	let textlabel = $(".siteWrapper").find("[data-id='"+id+"']");

	textlabel.remove();
}

function HideText(id) {
	let textlabel = $(".siteWrapper").find("[data-id='"+id+"']");

	textlabel.hide();
}

function ShowText(id) {
	let textlabel = $(".siteWrapper").find("[data-id='"+id+"']");

	textlabel.show();
}

function ShowMessageBox(message) {
	$('#mbox-message').html(Base64Decode(message));
	$('#globalMessageBox').css('display', 'block');
}

function HideMessageBox() {
	$('#globalMessageBox').css('display', 'none');
}

let InputEvent = "";

function ShowInputBox(message, button, localevent) {
	InputEvent = Base64Decode(localevent);

	let html = Base64Decode(message) + "<br><br><input id=\"input-box\" type=\"text\"><br><br><button class=\"input-button\">"+Base64Decode(button)+"</button>";

	$('#mbox-message').html(html);
	$('#globalMessageBox').css('display', 'block');
}

$(document).ready(function() {
	let messageBox = document.getElementById('globalMessageBox');
	
	$('.mbox-close').click(function() {
		HideMessageBox();
		CallEvent("OnHideMessageBox");
	});

	window.onclick = function(event) {
		if (event.target == messageBox) {
			HideMessageBox();
			CallEvent("OnHideMessageBox");
		}
	}

	$(document).keydown(function(e) {
		if (e.which == 27) {
			HideMessageBox();
			CallEvent("OnHideMessageBox");
		}
	});

	$(document).on('click', '.input-button', function() {
		let value = $("#input-box").val();
		
		HideMessageBox();
		CallEvent("OnHideMessageBox");
		
		if (InputEvent != "")
		{
			CallEvent(InputEvent, value);
			InputEvent = "";
		}
	});
});

function Base64Encode(str) {
    return btoa(encodeURIComponent(str).replace(/%([0-9A-F]{2})/g,
        function toSolidBytes(match, p1) {
            return String.fromCharCode('0x' + p1);
    }));
}

function Base64Decode(str) {
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}
