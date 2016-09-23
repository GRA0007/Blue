package ui.parts {
import flash.display.*;
import flash.text.*;
import flash.utils.*;
import scratch.*;
import translation.Translator;
import ui.media.*;
import ui.SpriteThumbnail;
import uiwidgets.*;
import flash.filters.DropShadowFilter;

public class LinesPart extends UIPart {

	//private var lastUpdate:uint; // time of last thumbnail update

	private var shape:Shape;


	public function LinesPart(app:Scratch) {
		this.app = app;
        shape = new Shape();
		addChild(shape);
		setWidthHeight(100,100);
	}


	public function setWidthHeight(w:int, h:int):void {
    //h=h-4;
		this.w = w;
		this.h = h;
		var g:Graphics = shape.graphics;
		g.clear();
        g.clear();
		g.lineStyle(1, 0x9E9E9E);

			g.moveTo(app.stagePart.x*0+app.stagePart.width, 0);
			g.lineTo(app.stagePart.x*0+app.stagePart.width, h);
            g.moveTo(0, app.stagePart.height-1);
			g.lineTo(app.stagePart.x*0+app.stagePart.width, app.stagePart.height-1);
			g.moveTo(0, app.stagePart.height-2);
			g.lineTo(app.stagePart.x*0+app.stagePart.width, app.stagePart.height-2);
			g.moveTo(0, app.stagePart.height);
			g.lineTo(app.stagePart.x*0+app.stagePart.width, app.stagePart.height);
			g.lineStyle();
            /*g.beginFill(0x9E9E9E);
            g.drawRect(app.stagePart.x+app.stagePart.width+1, 0, w-app.stagePart.x-app.stagePart.width, 30 );
            g.endFill();*/
		//if (app.viewedObj()) refresh(); // refresh, but not during initialization
	}





	// -----------------------------
	// Video Button
	//------------------------------



}}
