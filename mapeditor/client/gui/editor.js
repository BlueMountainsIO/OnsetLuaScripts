
$(document).ready(function() {

	//BuildSelectableObjects();

	$("#objectList").on('click', 'div', function() {
		let modelId = $(this).attr("data-id");

		CallEvent("OnObjectListSelect", modelId);
	});

	$("#objectExport").click(function() {
		let MapName = $('#mapName').val();

		CallEvent("OnObjectExport", MapName);
	});

	$("#editorSpeed").change(function() {
		let speed = $(this).val();

		CallEvent("OnEditorChangeSpeed", speed);
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

function BuildSelectableObjects(num_objects) {
	for (let i = 1; i < num_objects + 1; i++) {
		let object = '<div data-id="' + i + '" style="background-image: url(http://game/objects/' + i + ');">' + i + '</div>';
		$('#objectList').append(object);
	}
}

function SetObjectInfo(x, y, z, rx, ry, rz) {
	x = Math.round(x * 100) / 100;
	y = Math.round(y * 100) / 100;
	z = Math.round(z * 100) / 100;
	rx = Math.round(rx * 100) / 100;
	ry = Math.round(ry * 100) / 100;
	rz = Math.round(rz * 100) / 100;

	$("#locInfo span:nth-child(1)").text("X: " + x);
	$("#locInfo span:nth-child(2)").text("Y: " + y);
	$("#locInfo span:nth-child(3)").text("Z: " + z);
	
	$("#rotInfo span:nth-child(1)").text("X: " + rx);
	$("#rotInfo span:nth-child(2)").text("Y: " + ry);
	$("#rotInfo span:nth-child(3)").text("Z: " + rz);
}
