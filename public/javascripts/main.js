function expandAttachment(e) {
  var image = this.getElementsByTagName('img')[0];
  image.src = this.href;
  image.classList.toggle('attachment-sm');
  image.classList.toggle('attachment-md');
  e.preventDefault();
}

var attachments = document.getElementsByClassName('attachment-sm');
for (var attachment of attachments) {
  var link = attachment.parentElement.addEventListener('click', expandAttachment);
}
