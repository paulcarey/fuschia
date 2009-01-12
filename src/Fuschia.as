package {
    import com.adobe.serialization.json.JSON;
    
    import flare.display.TextSprite;
    import flare.vis.Visualization;
    import flare.vis.controls.ClickControl;
    import flare.vis.controls.Control;
    import flare.vis.controls.DragControl;
    import flare.vis.controls.HoverControl;
    import flare.vis.data.Data;
    import flare.vis.data.EdgeSprite;
    import flare.vis.data.NodeSprite;
    import flare.vis.data.render.ArrowType;
    import flare.vis.events.SelectionEvent;
    import flare.vis.operator.label.Labeler;
    import flare.vis.operator.layout.ForceDirectedLayout;
    import flare.vis.operator.layout.Layout;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    import flash.utils.IDataInput;

	
	[SWF(width="1000", height="700", backgroundColor="#ffffff", frameRate="30")]
	public class Fuschia extends Sprite
	{
		private var dbUri:String;
		
		private var metaData:Object;
		
		private var nodeMap:Dictionary = new Dictionary();
		private var edgeMap:Dictionary = new Dictionary();		
		
		private var vis:Visualization;
		private var data:Data = new Data();
		
		private var docDetail:TextSprite;
		private var docSummary:TextSprite;
		
		private var currentDate:Date;
		
		private var primaryDocDetail:String;
		private var primaryDocSummary:String;
		
		private var dbNameField:TextField;
		private var docIdField:TextField;
		
		private var nodeX:Number;
		private var nodeY:Number;
		
		public function Fuschia()
		{
			createVisualization();
		}
		
		private function createVisualization():void
		{
			nodeX = stage.stageWidth / 2
			nodeY = stage.stageHeight / 2;

			vis = new Visualization(data);
									
			vis.operators.add(createLayout());
			vis.continuousUpdates = true;
			
			// Failed to work consistently - no idea why
//			var llr:Labeler = new Labeler("data.label");
//			vis.operators.add(llr);
			
			vis.controls.add(createHoverControl());
			vis.controls.add(createClickControl());
			vis.controls.add(new DragControl(NodeSprite));
						
			addChild(vis);

			addChild(createDocDetail());	
			addChild(createDocSummary());	
			
			addChild(createDbNameField());
			addChild(createDbIdField());
			addChild(createLoadButton());												
		}
		
		private function createHoverControl():Control
		{
			return new HoverControl(NodeSprite,
				HoverControl.MOVE_AND_RETURN,
				function(e:SelectionEvent):void {
					e.node.lineWidth = 2;
					e.node.lineColor = 0x88ff0000;
					docDetail.text = docAsFormattedString(e.node.data.doc);
					docSummary.text = docSummaryStr(e.node.data.doc);
				},
				function(e:SelectionEvent):void {
					e.node.lineWidth = 0;
					e.node.lineColor = 0xff000000;
					docDetail.text = primaryDocDetail;
					docSummary.text = primaryDocSummary;
			});			
		}
		
		private function docAsFormattedString(doc:Object):String
		{
			var s:String = "";
			s += "_id" + " : " + doc._id + "\n";
			s += "_rev" + " : " + doc._rev + "\n";
			for (var n:Object in doc) {
				if (n !== "_id" && n !== "_rev") {
					s += n + " : " + JSON.encode(doc[n]) + "\n";
				}	
			}		
			return s;
		}
		
		private function createClickControl():Control
		{
			return new ClickControl(NodeSprite, 1,
				function(e:SelectionEvent):void {
					loadDataForDoc(e.node.data.doc._id);
				}
			);
		}
		
		private function createLayout():Layout
		{
			var layout:Layout = new ForceDirectedLayout(true);
			layout.parameters = {
				"simulation.dragForce.drag": 0.2,
				defaultParticleMass: 1,
				defaultSpringLength: 100,
				defaultSpringTension: 0.1
			};
			return layout;		
		}
		
		private function createDocDetail():TextSprite
		{
            docDetail = new TextSprite();
            docDetail.textMode = TextSprite.DEVICE;
            docDetail.textFormat = new TextFormat("Helvetica", 13);
            docDetail.x = 600;
            docDetail.y = 5;
			return docDetail;			
		}
		
		private function createDocSummary():TextSprite
		{
            docSummary = new TextSprite();
            docSummary.textMode = TextSprite.DEVICE;
            docSummary.textFormat = new TextFormat("Helvetica", 16);
            docSummary.x = 5;
            docSummary.y = 5;
			return docSummary;						
		}
		
		private function createDbNameField():TextField
		{
			dbNameField = new TextField();
			dbNameField.type = TextFieldType.INPUT;
			dbNameField.x = 5;
			dbNameField.y = 650;
			dbNameField.height = 15;
			dbNameField.width = 100;
			dbNameField.border = true;
			dbNameField.defaultTextFormat = new TextFormat("Helvetica", 12);
			dbNameField.text = "db name";
			return dbNameField;	
		}
		
		private function createDbIdField():TextField
		{
			docIdField = new TextField();
			docIdField.type = TextFieldType.INPUT;
			docIdField.x = 125;
			docIdField.y = 650;
			docIdField.height = 15;
			docIdField.width = 200;
			docIdField.border = true;
			docIdField.defaultTextFormat = new TextFormat("Helvetica", 12);
			docIdField.text = "doc id";
			return docIdField;	
		}

		private function createLoadButton():TextField
		{
			var tf:TextField = new TextField();
			tf.x = 345;
			tf.y = 650;
			tf.height = 15;
			tf.width = 28;
			var fmt:TextFormat = new TextFormat("Helvetica", 13);
			tf.defaultTextFormat = fmt;
			tf.text = "load";
			tf.addEventListener(MouseEvent.CLICK, function(evt:Event):void {
				nodeMap = new Dictionary();
				edgeMap = new Dictionary();
				data = new Data();
				vis.data = data;
				dbUri = dbNameField.text;
				if (dbUri.charAt(dbUri.length - 1) != "/") {
					dbUri += "/";
				}
				
				loadMetaData(docIdField.text);
			});
			return tf;	
		}
		
		private function loadMetaData(docId:String):void
		{
			var metaDataUri:String = dbUri + "fuschia";
			loadData(metaDataUri, function (doc:Object):void {
				metaData = doc;
				loadDataForDoc(docId);
			});
		}
				
		private function displayPrimaryDoc(doc:Object):void
		{
			primaryDocDetail = docAsFormattedString(doc);
			primaryDocSummary = docSummaryStr(doc);		
			docDetail.text = primaryDocDetail;
			docSummary.text = primaryDocSummary;
			var ns:NodeSprite = displayDoc(doc);
			nodeX = ns.x;
			nodeY = ns.y;
		}
		
		private function displayDoc(doc:Object):NodeSprite
		{
			var ns:NodeSprite =	getNodeSprite(doc._id);
			ns.data.doc = doc;
			ns.data.label = docSummaryStr(doc);				
			ns.fillColor = docFillColor(doc);				
			return ns;
		}
		
		private function docSummaryStr(doc:Object):String
		{
			var summary:String = "";
			var docMetaData:Object = metaData[doc[metaData.classProperty]];
			if (docMetaData) {
				var kp:String = docMetaData.summaryProperty;
				summary = kp ? doc[kp] : "";
			}
			return summary.substring(0, 30);
		}
		
		private function docFillColor(doc:Object):Number
		{
			var fillColor:Number = 0xffcccccc;
			var docMetaData:Object = metaData[doc[metaData.classProperty]];
			if (docMetaData) {
				fillColor = docMetaData.fillColor ? docMetaData.fillColor : 0xffcccccc;
			}
			return fillColor;
		}
		
		private function displayInDocs(result:Object):void
		{
			for each (var r:Object in result.rows) {
				var es:EdgeSprite = getEdgeSprite(r.id, r.key);
			}
		}
		
		private function displayOutDocs(result:Object):void
		{
			for each (var r:Object in result.rows) {
				var es:EdgeSprite = getEdgeSprite(r.key, r.value);
			}
		}
		
		private function loadDataForDoc(id:String):void
		{
			var docUri:String = dbUri + id;
			var fromDocUri:String = dbUri + "_view/fuschia/from_doc?key=\"" + id + "\"";
			var toDocUri:String = dbUri + "_view/fuschia/to_doc?key=\"" + id + "\"";
					
			loadData(docUri, displayPrimaryDoc);
			loadData(fromDocUri, displayOutDocs);
			loadData(toDocUri, displayInDocs);
		}
		
		private function loadData(uri:String, func:Function):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE,
				function(evt:Event):void {
					var input:IDataInput = loader.data;
					var text:String = input.readUTFBytes(input.bytesAvailable);
					var data:Object = JSON.decode(text) as Object;
					func(data);
				}
			);
			loader.load(new URLRequest(uri));
		}
		
		private function getNodeSprite(docId:Object):NodeSprite
		{
			trace("getNode: " + docId);
			var ns:NodeSprite = nodeMap[docId];
			if (ns == null) {
				loadData(dbUri + docId, displayDoc);
				ns = data.addNode({id:docId});
				ns.x = nodeX;
				ns.y = nodeY;
				nodeMap[docId] = ns;
			}	
			return ns;
		}
		
		private function getEdgeSprite(source_id:Object, target_id:Object):EdgeSprite
		{
			var edgeId:String = source_id + "_" + target_id;
			var otherEdgeId:String = target_id + "_" + source_id;
			trace("getEdge: " + edgeId);
			
			var es:EdgeSprite = edgeMap[edgeId];
			if (es == null) {
				trace("adding edge: " + edgeId);
				var source:NodeSprite = getNodeSprite(source_id);
				var target:NodeSprite = getNodeSprite(target_id);
				es = data.addEdgeFor(source, target, true);
				es.arrowType = ArrowType.TRIANGLE;
				es.arrowWidth = 15;				
				edgeMap[edgeId] = es;
			}
			
			// Remove the other edge as a workaround for apparently ineffectual
			// sort orders - defining a z-index and sorting on it only has the
			// desired effect on the first draw
			var otherEs:EdgeSprite = edgeMap[otherEdgeId];
			if (otherEs != null) {
				trace("removing edge: " + otherEdgeId);
				data.removeEdge(otherEs);	
				delete edgeMap[otherEdgeId];
			}
			return es;
		}		
		
	}
}
