/*Copyright (c) 2009 De Pannekoek en De Kale B.V.,  www.dpdk.nlPermission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the "Software"), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included inall copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS ORIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHERLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS INTHE SOFTWARE. */package nl.dpdk.utils.timeline {	import flash.display.MovieClip;	import flash.display.Scene;	import flash.events.Event;	import flash.events.EventDispatcher;	[Event(name="NEW_LABEL", type="nl.dpdk.utils.TimelineEvent")]	[Event(name="NEW_SCENE", type="nl.dpdk.utils.TimelineEvent")]	[Event(name="TIMELINE_END", type="nl.dpdk.utils.TimelineEvent")]	/**	 * TimelineListener is a class that enables you to listen to Events that provide information of where the playhead is in a movieclip / timeline.	 * A listener can be informed when a new scene is reached on the timeline.	 * A listener can be informed when a new framelabel is reached on the timeline.	 * A listener can be informed when a timeline has reached it's end.	 * 	 * @usage	 * import nl.dpdk.utils.TimelineListener;	 * import nl.dpdk.utils.TimelineEvent	 * private var t: TimelineListener;	 * 	 * t = new TimelineListener(someMovieClip);	 * t.addEventListener(TimelineEvent.NEW_LABEL, onNewLabel);	 * t.addEventListener(TimelineEvent.NEW_SCENE, onNewScene);	 * t.addEventListener(TimelineEvent.TIMELINE_END, onTimelineEnd);	 * 	 * private function onNewLabel(event: TimelineEvent):void{	 * 	trace("new label reached: '" + event.getLabel() + "', on frame: " + event.getFrame() + " in scene:  '" + event.getScene().name + "' in the movieclip: " + event.getTimeline());	 * 	t.destroy();	 * 	t = null;	 * }	 * 	 * 	 * 	 * @see nl.dpdk.utils.TimelineEvent	 * 	 * @author rolf vreijdenberger	 */	public class TimelineListener extends EventDispatcher {				private var timeline : MovieClip;		private var scene : Scene;		private var label : String;		private var frame : uint;		/**		 * @param timeline the MovieClip whose timeline we want to listen to for events.		 */		public function TimelineListener(timeline : MovieClip) {			this.timeline = timeline;			label = timeline.currentLabel;			scene = timeline.currentScene;			frame = timeline.currentFrame;			timeline.addEventListener(Event.ENTER_FRAME, listen);		}		/**		 * the enterframe event handler.		 */		private function listen(event : Event) : void {			//trace("TimelineListener.listen() label: " + timeline.currentLabel + ", frame: " + timeline.currentFrame + ", scene: " + timeline.currentScene.name);			/**			 * TODO, it seems there is a bug in fp10 cs4 because when using different scenes which all contain framelables, 			 * the last labelled or unlabelled frame sequence in the first sequence gets the labelname of the last labelled frame in the last scene.			 * After this, the currentLabel propertie stays at that value			 */			 			/**			 * try/catch is used to prevent the runtime error when using the TIMELINE_END event handler to destroy() the TimelineListener (or any other event handler for TimelineEvents)			 * The error happens because after the event is dispatched the update on the 'frame' propertie still tries to use 'timeline' which has then been set to null.			 */			try {				//check if we have reached a different label.				if(timeline.currentLabel != label) {					label = timeline.currentLabel;					scene = timeline.currentScene;					dispatchEvent(new TimelineEvent(TimelineEvent.NEW_LABEL, timeline.currentFrame, label, timeline.currentScene, timeline));					}							//check if we have reached a different scene				if(timeline.currentScene.name != scene.name) {					scene = timeline.currentScene;						label = timeline.currentLabel;					dispatchEvent(new TimelineEvent(TimelineEvent.NEW_SCENE, timeline.currentFrame, label, scene, timeline));					}							//check if we are at the end of a timeline				//we need to check the frames in the current scene: timeline.totalFrames gives the total frames over all scenes				if(timeline.currentFrame == timeline.currentScene.numFrames && frame != timeline.currentFrame) {					frame = timeline.currentFrame;					dispatchEvent(new TimelineEvent(TimelineEvent.TIMELINE_END, frame, label, scene, timeline));					}							//update so we can use it for only dispatching 1 TimelineEvent.TIMELINE_END when stopped at the last keyframe of a MovieClip				frame = timeline.currentFrame;			}catch(e : Error) {				trace("TimelineListener.listen() expected error: " + e.message);			}		}		/**		 * cleans up the internals of the class.		 * call this method before releasing the reference		 */		public function destroy() : void {			try {				timeline.removeEventListener(Event.ENTER_FRAME, listen);				timeline = null;					label = null;				frame = 1;				scene = null;			}catch(e : Error) {				trace("TimelineListener.destroy() expected error: " + e.message);			}		}		/**		 * gets the current framelable		 */		public function getLabel() : String {			return timeline.currentLabel;		}		/**		 * gets the current frame number		 */		public function getFrame() : uint {			return timeline.currentFrame;			}		/**		 * gets a reference to the timeline / MovieClip we are listening to		 */		public function getTimeline() : MovieClip {			return timeline;		}		/**		 * get a reference to the current scene		 */		public function getScene() : Scene {			return timeline.currentScene;		}	}}