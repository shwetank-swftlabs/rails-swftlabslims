import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Run after a small delay to ensure DOM is fully rendered
    setTimeout(() => {
      this.replaceZeroPointZeroZeroOne()
    }, 100)
  }

  replaceZeroPointZeroZeroOne() {
    // Walk through all text nodes in the document
    const walker = document.createTreeWalker(
      document.body,
      NodeFilter.SHOW_TEXT,
      {
        acceptNode: function(node) {
          // Skip script, style, and input/textarea tags (to preserve form values)
          const parent = node.parentElement
          if (!parent) return NodeFilter.FILTER_REJECT
          
          const tagName = parent.tagName
          if (tagName === 'SCRIPT' || 
              tagName === 'STYLE' || 
              tagName === 'INPUT' || 
              tagName === 'TEXTAREA') {
            return NodeFilter.FILTER_REJECT
          }
          
          // Only process if the text contains "0.001"
          if (node.textContent && node.textContent.includes('0.001')) {
            return NodeFilter.FILTER_ACCEPT
          }
          
          return NodeFilter.FILTER_REJECT
        }
      }
    )

    const textNodes = []
    let node
    while (node = walker.nextNode()) {
      textNodes.push(node)
    }

    // Replace 0.001 with NA in each text node
    textNodes.forEach(textNode => {
      // Only replace standalone "0.001" (word boundaries ensure it's not part of a larger number)
      // This regex matches 0.001 as a standalone value
      const originalText = textNode.textContent
      const newText = originalText.replace(/\b0\.001\b/g, 'NA')
      
      if (newText !== originalText) {
        textNode.textContent = newText
      }
    })
  }
}

