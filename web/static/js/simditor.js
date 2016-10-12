import $ from "jquery";
import Simditor from "simditor";
import "to-markdown";
import "marked";
import "simditor-markdown";

(function() {
  $(function() {
    let $simditor_textarea = $('.simditor-textarea');

    if ($simditor_textarea.length > 0) {
      new Simditor({
        textarea: $simditor_textarea,
        markdown: true,
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
          'alignment',
          'markdown'
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
        markdown: true,
        toolbar: [
          'bold',
          'ol',
          'ul',
          'blockquote',
          'link',
          'alignment',
          'markdown'
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
