@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.FieldDeclarationsShouldBeAtStart, PMD.EmptyStatementBlock')
/**
 * @description Trigger Handler virtual class as base for all trigger handlers
 * @author {@link [Kevin OHara](https://github.com/kevinohara80)}
 * @group Trigger Handler
 * @see TriggerHandlerTest
 */
public virtual class TriggerHandler {
	/**
	 * Map of `handlerName` => times `run()` was invoked
	 * @description The name of this handler. Set by `getHandlerName()`
	 */


   	/**
	 * @description Constructor with handler name to improve performance
	 * @param  handlerName The name of the handler
	 * @example
	 * new AccountSampleTriggerHandler('AccountSampleTriggerHandler').run();
	 * // (in Trigger Handler)
	 * public AccountSampleTriggerHandler('AccountSampleTriggerHandler') {
	 *   this.newRecords = (List<Account>) Trigger.new;
	 *   this.oldRecords = (List<Account>) Trigger.old;
	 *   this.newRecordsMap = (Map<Id, Account>) Trigger.newMap;
	 *   this.oldRecordsMap = (Map<Id, Account>) Trigger.oldMap;
	 * }
	 */

	public TriggerHandler(String handlerName) {
		this.handlerName = handlerName;
		this.setTriggerContext();
	}

  public TriggerHandler() {
    this.setTriggerContext();
  }


  /***************************************
   * private static variables
   ***************************************/

  private String handlerName;

  @TestVisible
  private static Map<String, LoopCount> loopCountMap;
	@TestVisible
  private static Set<String> bypassedHandlers;

	/**
	 * The current triggerEvent of the trigger, overridable in tests
	 */

  @TestVisible
  private System.TriggerOperation context;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

    // the current context of the trigger, overridable in tests
  @TestVisible
  private static Boolean showLimits;
  
    /**
     * `true` if we include a debug statement for trigger entry and exit
     */
  @TestVisible
  private static Boolean showDebug;  

  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
    showLimits = false;
		showDebug = false;
  }



  /***************************************
   * public instance methods
   ***************************************/

  // main method that will be called during execution
  public void run() {

    Boolean isActive = false;
    if( Trigger_Setting__mdt.getInstance(getHandlerName())?.Is_Active__c != null ){
      isActive = Trigger_Setting__mdt.getInstance(getHandlerName()).Is_Active__c ;
    }else if(Test.isRunningTest()){
      isActive = true;
    }
    

    if(!validateRun()) {
      return;
    }

    if(!addToLoopCount()) {
      return;
    }


    if (showDebug) {
    System.debug('Is Trigger Active : '+isActive);
    System.debug('handler and context : '+getEventHandlerName());
    System.debug('Trigger Event : '+this.context);
   // System.debug('Max Count : '+ TriggerHandler.loopCountMap.get(getEventHandlerName()).getMax() +': Count :'+ TriggerHandler.loopCountMap.get(getEventHandlerName()).getCount() );
    }

    if(isActive){
   
    // dispatch to the correct handler method
    switch on this.context {
      when BEFORE_INSERT {
        this.beforeInsert();
      }
      when BEFORE_UPDATE {
        this.beforeUpdate();
      }
      when BEFORE_DELETE {
        this.beforeDelete();
      }
      when AFTER_INSERT {
        this.afterInsert();
      }
      when AFTER_UPDATE {
        this.afterUpdate();
      }
      when AFTER_DELETE {
        this.afterDelete();
      }
      when AFTER_UNDELETE {
        this.afterUndelete();
      }
    }
      this.andFinally();
    }
    

		if (showLimits) {
			System.debug(
				LoggingLevel.DEBUG,
				String.format(
					'{0} on {1} ({2}/{3} queries) and ({4}/{5} DML calls)',
					new List<String>{
						this.context + '',
						getHandlerName(),
						Limits.getQueries() + '',
						Limits.getLimitQueries() + '',
						Limits.getDmlStatements() + '',
						Limits.getLimitDmlStatements() + ''
					}
				)
			); // NOPMD
		}
		if (showDebug) {
			System.debug(LoggingLevel.DEBUG, String.format('Exiting {0}, fired {1}', new List<String>{ getHandlerName(), this.context + '' })); // NOPMD
		}
  }

  public void setMaxLoopCount(Integer max) {
        // FBO to realy manage loops, we need to check wich event is going to be restart not the Handlername (this last is for all this trigger's events )
    String handlerName = getEventHandlerName();
    if(!TriggerHandler.loopCountMap.containsKey(handlerName)) {
      TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerHandler.loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  /***************************************
   * public static methods
   ***************************************/

  public static void bypass(String handlerName) {
    TriggerHandler.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    TriggerHandler.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return TriggerHandler.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    TriggerHandler.bypassedHandlers.clear();
  }

  /**
	 * @description   Called before the trigger to enable the class to debug (or not) query limits when it runs.
	 * <br>Set to true to show limits.
	 * <br>Use this in the trigger or handler
	 *
	 * @param enabled true to enable; false to disable
	 * @see TriggerHandler.showLimits[0]
	 */
	public static void showLimits(Boolean enabled) {
		if (enabled == null) {
			showLimits = false;
		} else if (enabled) {
			showLimits = true;
		} else {
			showLimits = false;
		}
	}

  /**
	 * @description   Called in the trigger to force the class to debug trigger entry and exit with context.
	 * <br>Set to true to show entry and exit.
	 * @param enabled true to enable; false to disable
	 * @see TriggerHandler.showDebug[0]
	 */
	public static void showDebug(Boolean enabled) {
		if (enabled == null) {
			showDebug = false;
		} else if (enabled) {
			showDebug = true;
		} else {
			showDebug = false;
		}
	}

  /***************************************
   * private instancemethods
   ***************************************/
  @TestVisible
  private void setTriggerContext() {
    this.setTriggerContext(null, false);
  }

  @TestVisible
  private void setTriggerContext(System.TriggerOperation ctx, Boolean testMode) {
    String strContext ;
    if(!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      strContext = Trigger.operationType?.name();
      return;
    } else {
      this.isTriggerExecuting = true;
      this.context = ctx;
      strContext = String.valueOf(ctx);
    }
    
    
     System.debug('Trigger event'+ ctx);
    System.debug('Trigger event'+ strContext);
    System.debug('Trigger event non String'+ context);
		switch on strContext{
			when 'BEFORE_INSERT' {
				this.context = System.TriggerOperation.BEFORE_INSERT;
			}
			when 'BEFORE_UPDATE' {
				this.context = System.TriggerOperation.BEFORE_UPDATE;
			}
			when 'BEFORE_DELETE' {
				this.context = System.TriggerOperation.BEFORE_DELETE;
			}
			when 'AFTER_INSERT' {
				this.context = System.TriggerOperation.AFTER_INSERT;
			}
			when 'AFTER_UPDATE' {
				this.context = System.TriggerOperation.AFTER_UPDATE;
			}
			when 'AFTER_DELETE' {
				this.context = System.TriggerOperation.AFTER_DELETE;
			}
			when 'AFTER_UNDELETE' {
				this.context = System.TriggerOperation.AFTER_UNDELETE;
			}
			when else {
				// we are not in trigger context
				this.isTriggerExecuting = false;
			}
		}
  }

  // increment the loop count
  @TestVisible
  private boolean addToLoopCount() {
    String handlerName = getEventHandlerName();
    if(TriggerHandler.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
      if(exceeded) {
        Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
       // throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
       System.debug('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName + 'count :'+TriggerHandler.loopCountMap.get(handlerName).count);
       return false;
      }
      return true;
    }
    return true;
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() {
    if(!this.isTriggerExecuting || this.context == null) {
      throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
    }
    return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
  }


	/**
	 * @description Get the name of the current handler. This can be set by using the constructor with the string parameter to improve performance
	 *
	 * @return      `String` Name of the current handler
	 * @see         TriggerHandler.handlerName
	 */
	@TestVisible
	private String getHandlerName() {
		if (String.isBlank(this.handlerName)) {
			this.handlerName = this.toString().substringBefore(':');
		}
		return this.handlerName;
	}
  
  @TestVisible
  private String getEventHandlerName() {
      return (getHandlerName() + this.context) ;
  }


  /***************************************
   * context methods
   ***************************************/

  // context-specific methods for override
  @TestVisible
  protected virtual void beforeInsert(){}
  @TestVisible
  protected virtual void beforeUpdate(){}
  @TestVisible
  protected virtual void beforeDelete(){}
  @TestVisible
  protected virtual void afterInsert(){}
  @TestVisible
  protected virtual void afterUpdate(){}
  @TestVisible
  protected virtual void afterDelete(){}
  @TestVisible
  protected virtual void afterUndelete(){}
  	
  /**
	 * @description `andFinally` is called in every context, regardless of Trigger context
	 * <br>Credit to James Simone for this idea
	 * @see [The Joys of Apex](https://www.jamessimone.net/blog/joys-of-apex/lightweight-trigger-handler/)
	 * @author James Simone
	 * @since 2022
	 * */
	@TestVisible
	protected virtual void andFinally() {
	}

  /***************************************
   * inner classes
   ***************************************/

  // inner class for managing the loop count per handler
  @TestVisible
  private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    /**
		 * @description Constructor with specified max loops
		 *
		 * @param max   Max number of loops allowed
		 */
    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

   	/**
		 * @description Increment the internal counter returning the results of
		 * this.exceeded().
		 * @return     `Boolean` true if count will exceed max count or is less
		 * than 0.
		 */
    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }
		/**
		 * @description Determines if we're about to exceed the loop count.
		 * @return     `Boolean` True if less than 0 or more than max.
		 */
    public Boolean exceeded() {
      return this.max >= 0 && this.count > this.max;
    }

    /**
		 * @description Returns the max loop count.
		 * @return     `Integer` Max loop count.
		 */
    public Integer getMax() {
      return this.max;
    }

    /**
		 * @description Returns the current loop count.
		 * @return     `Integer` Current loop count.
		 */
    public Integer getCount() {
      return this.count;
    }

    /**
		 * @description Sets the max loop count
		 * @param max   The integer to set max to.
		 */
    public void setMax(Integer max) {
      this.max = max;
    }
  }

  	/**
	 * @description Exception class
	 */
  public class TriggerHandlerException extends Exception {
  }

}