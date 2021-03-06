package fr.unice.i3s.uca4svr.toucan_vr.dynamicEditing.operations;

import com.google.android.exoplayer2.ExoPlayer;

import org.gearvrf.GVRContext;
import org.gearvrf.GVRSceneObject;
import org.gearvrf.scene_objects.GVRVideoSceneObjectPlayer;

import fr.unice.i3s.uca4svr.toucan_vr.dynamicEditing.DynamicEditingHolder;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.DynamicOperationsTracker;
import fr.unice.i3s.uca4svr.toucan_vr.tracking.HeadMotionTracker;

/**
 * General dynamic operation implementation.
 * Stores the timing system and the abstract method that each concrete dynamic operation has to implement and specify.
 *
 * @author Julien Lemaire
 */
public abstract class DynamicOperation {
  private int milliseconds;
  private boolean millisecondsFlag;
  protected boolean triggered;
  protected boolean decided;
  protected DynamicEditingHolder dynamicEditingHolder;

  protected float mean_input_trigger;
  protected float proba_trigger;
  protected int op_index;

  public DynamicOperation(DynamicEditingHolder dynamicEditingHolder) {
    this.millisecondsFlag = false;
    this.dynamicEditingHolder = dynamicEditingHolder;
    this.decided = false;
    this.triggered = false;
  }

  public boolean getTriggered(){ return this.triggered;}
  public void setTriggered( boolean trig){ this.triggered = trig;}
  public boolean getDecided(){ return this.decided;}
  public void setDecided( boolean decision){ this.decided = decision;}

  public float getInput(){ return this.mean_input_trigger;}
  public void setInput( float meanInput){ this.mean_input_trigger = meanInput;}
  public float getProba(){ return this.proba_trigger;}
  public void setProba( float proba){ this.proba_trigger = proba;}
  public int getIndex(){ return this.op_index;}
  public void setIndex( int index){ this.op_index = index;}

  public int getMilliseconds() {
    return this.milliseconds;
  }

  public long getMicroseconds() {
    return this.milliseconds*1000;
  }

	public void setMilliseconds(int milliseconds) {
		this.milliseconds = milliseconds;
		this.millisecondsFlag = true;
	}

	public boolean isWellDefined() {
    return this.millisecondsFlag;
  }

  public boolean isReady(long currentTime) {
    return currentTime > this.milliseconds
      || (this.milliseconds - currentTime) < dynamicEditingHolder.timeThreshold;
  }

  public abstract void activate(GVRVideoSceneObjectPlayer<ExoPlayer> player, GVRSceneObject videoHolder, HeadMotionTracker headMotionTracker, DynamicOperationsTracker tracker);

  public abstract boolean hasToBeTriggeredInContext(GVRContext gvrContext);

  public abstract void logIn(DynamicOperationsTracker tracker, long executionTime);

  public abstract int computeIdealTileIndex(int selectedIndex, int adaptationSetIndex, long nextChunkStartTimeUs);

  public abstract void deactivate(GVRSceneObject videoHolder,GVRVideoSceneObjectPlayer<ExoPlayer> player);
}
