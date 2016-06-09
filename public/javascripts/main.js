function expandAttachment(e) {
  var thumbnail = this.getElementsByTagName('img')[0];
  if (/\.(jpg|png|gif)$/.test(this.href)) {
    thumbnail.src = this.href;
    thumbnail.classList.toggle('attachment');
  } else if (/\.(webm|mp4)$/.test(this.href)) {
    var parent = this.parentElement;
    var href = this.href;
    this.remove();
    var video = document.createElement('video');
    var source = document.createElement('source');
    source.src = href;
    video.appendChild(source);
    video.controls = true;
    parent.appendChild(video);
    video.play();
  }
  e.preventDefault();
}

var attachments = document.getElementsByClassName('attachment');
for (var attachment of attachments) {
  var link = attachment.parentElement.addEventListener('click', expandAttachment);
}
