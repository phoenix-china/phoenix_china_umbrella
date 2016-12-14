import Simditor from "simditor";
import "to-markdown";
import "marked";
import "simditor-markdown";

(function() {
    const simditor_textarea = document.querySelector(".simditor-textarea");

    if (simditor_textarea) {
      new Simditor({
        textarea: simditor_textarea,
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
    }

    const simditor_comment_textarea = document.querySelector('.simditor-comment-textarea');

    if (simditor_comment_textarea) {
      new Simditor({
        textarea: simditor_comment_textarea,
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

})();
