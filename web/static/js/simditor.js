import $ from "jquery";
import Simditor from "simditor";

(function() {
  $(function() {
    let $simditor_textarea = $('.simditor-textarea');

    if ($simditor_textarea.length > 0) {
      new Simditor({
        textarea: $simditor_textarea,
        toolbar: [
          'title',
          'bold',
          'italic',
          'underline',
          'strikethrough',
          'fontScale',
          'color',
          'ol',
          'ul',
          'blockquote',
          'link',
          'hr',
          'indent',
          'outdent',
          'alignment'
        ],
        imageButton: 'upload',
        pasteImage: true,
        upload: {
          url: "/editor/upload",
          fileKey: "file"
        }
      });
    };

    let $simditor_comment_textarea = $('.simditor-comment-textarea');

    if ($simditor_comment_textarea.length > 0) {
      new Simditor({
        textarea: $simditor_comment_textarea,
        toolbar: [
          'bold',
          'ol',
          'ul',
          'blockquote',
          'link',
          'alignment'
        ],
        imageButton: 'upload',
        pasteImage: true,
        upload: {
          url: "/editor/upload",
          fileKey: "file"
        }
      });
    };
  });
})();
