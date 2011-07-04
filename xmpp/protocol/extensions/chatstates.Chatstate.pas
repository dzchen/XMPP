unit chatstates.Chatstate;

interface
type
  TChatstate=(
   /// <summary>
        /// No Chatstate at all
        /// </summary>
        None,
        /// <summary>
        /// Active Chatstate
        /// </summary>
        active,
        /// <summary>
        /// Inactive Chatstate
        /// </summary>
        inactive,
        /// <summary>
        /// Composing Chatstate
        /// </summary>
        composing,
        /// <summary>
        /// Gone Chatstate
        /// </summary>
        gone,
        /// <summary>
        /// Paused Chatstate
        /// </summary>
        paused
  );

implementation

end.
