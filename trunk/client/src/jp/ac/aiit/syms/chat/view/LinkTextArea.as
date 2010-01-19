package jp.ac.aiit.syms.chat.view
{
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	
	import mx.controls.TextArea;
	import mx.controls.textClasses.TextRange;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;

	use namespace mx_internal;
		
	public class LinkTextArea extends TextArea
	{
		public var ss:StyleSheet = new StyleSheet();
		public function LinkTextArea()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		protected function onCreationComplete(pEvent:FlexEvent):void
		{
			selectable = true;
			// create styles in the stylesheet
			defineStyles();
			// apply the stylesheet to the StyledTextArea control
			this.styleSheet = this.ss;

		}

		// Override the electable property so we can turn our custom onclick handler
		// on if selectable is set to true. If it's set to false, we remove the
		// listener so the text area can handle things as usual.
		override public function set selectable(pSelectable:Boolean):void
		{
			super.selectable = pSelectable;
			if (textField)
			{
				textField.selectable = pSelectable;
			}
			else
			{
				// If we're attempting to set selectable before the component
				// has completed its instantiation, we need to postpone
				// passing the command on to the textField (which won't have
				// been created yet) until instantiation has completed.
				callLater(function(pSelectable:Boolean):void
				{
					textField.selectable = pSelectable;
				}, [pSelectable]);
			}
			if (!pSelectable)
			{
				addEventListener(MouseEvent.CLICK, onClick);
			}
			else
			{
				UITextField(textField).setSelection(-1, -1);
				removeEventListener(MouseEvent.CLICK, onClick);
			}
		}

		protected function onClick(pEvent:MouseEvent):void
		{
			// Find the letter under our click
			var index:int = textField.getCharIndexAtPoint(pEvent.localX, pEvent.localY);
			if (index != -1)
			{
				// convert the letter to a text range so we can extract the url
				var range:TextRange = new TextRange(this, false, index, index + 1);
				// make sure it contains a url
				if (range.url.length > 0)
				{
					// if the text area is not editable, select the letter
					if (!editable)
					{
						UITextField(textField).setSelection(index, index + 1);
					}
					// The normal click event strips out the 'event;' portion of the url.
					// So to be consistent, let's strip it out, too.
					var url:String = range.url;
					if (url.substr(0, 6) == 'event:')
					{
						url = url.substring(6);
					}
					// Manually dispatch the link event with the url neatly included
					dispatchEvent(new TextEvent(TextEvent.LINK, false, false, url));
					// unselect the letter
					if (!editable)
					{
						UITextField(textField).setSelection(-1, -1);
					}
				}
			}
		}
	
		public function defineStyles():void
		{
	 		
			var aHover:Object = new Object();
			aHover.textDecoration = "underline";
			aHover.color = "#f19b32";
	        
	        var aLink:Object = new Object();
	        aLink.textDecoration = "underline";
	        aLink.color = "#0000ff";
	        
	        var aActive:Object = new Object();
	        aActive.textDecoration = "underline";
	        aActive.color = "#35a809";
	        
	        var a:Object = new Object();
	        a.color = "#0066FF";
	        a.textDecoration = "underline";
	        
	        ss.setStyle("a", a);
	        ss.setStyle("a:hover", aHover);
	        ss.setStyle("a:link", aLink);
	        ss.setStyle("a:active", aActive);
		}
	}
}