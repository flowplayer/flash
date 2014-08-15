package org.osmf.examples.buffering
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * ParallelElement which attempts to synchronize its children by pausing
	 * any time one child is buffering.
	 * 
	 * Note that there's a bug (FM-1044) where the entire ParallelElement will
	 * pause when the shortest element reaches its duration.
	 **/
	public class SynchronizedParallelElement extends ParallelElement
	{
		public function SynchronizedParallelElement()
		{
			addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
			
			// Bufferable's bufferLength must be polled for. Setup a
			// timer to do so:
			bufferLengthPoller = new Timer(500, 0);
			bufferLengthPoller.addEventListener(TimerEvent.TIMER, onBufferLengthPoll);
			
			super();
		}
		
		// Internals
		//
		
		private var bufferable:BufferTrait;
		private var playable:PlayTrait;
		private var paused:Boolean;
		private var bufferLengthPoller:Timer;
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			// Watch for the element to become bufferable and playable:
			switch (event.traitType)
			{
				case MediaTraitType.BUFFER:
					bufferable = BufferTrait(getTrait(event.traitType));
					bufferable.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, updatePlayState);
					bufferLengthPoller.start();
					updatePlayState();
					break;
					
				case MediaTraitType.PLAY:
					playable = PlayTrait(getTrait(event.traitType));
					updatePlayState();
					break;
			} 
		}
		
		private function onTraitRemove(event:MediaElementEvent):void
		{
			switch (event.traitType)
			{
				case MediaTraitType.BUFFER:
					bufferLengthPoller.stop();
					bufferable.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE, updatePlayState);
					bufferable = null;
					updatePlayState();
					break;
					
				case MediaTraitType.PLAY:
					playable = null;
					updatePlayState();
					break;
			} 
		}
		
		private function updatePlayState(..._):void
		{
			if (playable && playable.canPause && bufferable)
			{
				if 	(	paused == true
					&&	playable.playState == PlayState.PAUSED
					&& 	bufferable.bufferLength >= bufferable.bufferTime
					)
				{
					// We have paused the content earlier on. Buffering
					// has seized though, so we can resume playback:
					paused = false;
					playable.play();
				}
				else if
					(	paused == false
					&& 	bufferable.bufferLength < bufferable.bufferTime
					)
				{
					// At least part of the content is in a buffering
					// state. Pause the parallel element as a whole,
					// if it isn't already:
					paused = true;
					if (playable.playState != PlayState.PAUSED)
					{
						playable.pause();
					}
				}
			}
		}
		
		private function onBufferLengthPoll(event:TimerEvent):void
		{
			if (playable && playable.canPause && bufferable)
			{
				// Check if the element is in a buffering state,
				// and update the playstate accordingly:
				updatePlayState();
			}
		}
	}
}