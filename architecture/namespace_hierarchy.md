CodeMySpec [module]
├── AcceptanceCriteria [context]
│   ├── AcceptanceCriteriaRepository [module] Repository for acceptance criteria CRUD operations with direct database access. Provides query composables for filter...
│   └── Criterion [module] Ecto schema representing a single acceptance criterion. Contains the description text, verification status, and belon...
├── Accounts [module] The Accounts context manages multi-tenant account architecture with personal and team accounts, user membership relat...
│   ├── Account [module] Ecto schema representing user accounts in the multi-tenant system. Accounts can be either personal (belonging to a si...
│   ├── AccountsRepository [module] Data access layer for account entities, handling personal and team account creation, basic account operations, and qu...
│   ├── Member [module] Ecto schema managing the many-to-many relationship between accounts and users with role-based permissions. Supports a...
│   └── MembersRepository [module] Provides data access layer for account membership relationships, handling user addition/removal, role management, and...
├── AgentTasks [module]
│   ├── ArchitectureDesign [module]
│   ├── ArchitectureReview [module]
│   ├── ComponentCode [module]
│   ├── ComponentSpec [module] Agent task module for generating component specification documents via Claude Code slash commands. This module orches...
│   ├── ComponentTest [module]
│   ├── ContextComponentSpecs [module] Agent task for designing a context and all its child components through orchestrated subagent workflow.
│   ├── ContextDesignReview [module]
│   ├── ContextImplementation [logic]
│   ├── ContextSpec [module]
│   ├── DesignUi [module]
│   ├── DevelopComponent [module]
│   ├── DevelopContext [module] Orchestrates the full lifecycle of a context from specification through implementation. Creates prompt files for all ...
│   ├── DevelopController [module]
│   ├── DevelopLiveContext [module]
│   ├── DevelopLiveView [context]
│   ├── FixAllBddSpecs [module]
│   ├── FixBddSpecs [agent_task]
│   ├── FixIssues [module]
│   ├── LiveContextSpec [module]
│   ├── LiveViewCode [module]
│   ├── LiveViewSpec [module]
│   ├── LiveViewTest [module]
│   ├── ManageImplementation [module] State machine that orchestrates the full implementation lifecycle of a project. Directly delegates to WriteBddSpecs, ...
│   ├── ProblemFeedback [module]
│   ├── ProjectBootstrap [module]
│   ├── ProjectSetup [module]
│   ├── QaApp [module]
│   ├── QaJourneyExecute [module]
│   ├── QaJourneyPlan [module]
│   ├── QaJourneyWallaby [module]
│   ├── QaSetup [module]
│   ├── QaStory [module]
│   ├── RefactorModule [module] Agent task for guiding interactive refactoring sessions with Claude Code. Routes to component or context-specific ref...
│   ├── ResearchTopic [module]
│   ├── ResearchTopics [module]
│   ├── StartAgentTask [module]
│   ├── StartImplementation [module]
│   ├── TaskContext [module]
│   ├── TaskMarker [module]
│   ├── TechnicalStrategy [module]
│   ├── TrackEdits [module]
│   ├── TriageIssues [module]
│   └── WriteBddSpecs [agent_task]
├── Architecture [module] A coordination context that generates and maintains text-based architectural views for AI agent consumption. Provides...
│   ├── MermaidProjector [module]
│   ├── NamespaceProjector [module]
│   ├── OverviewProjector [module]
│   ├── Proposal [module] Represents an architecture proposal for a greenfield project. A proposal contains bounded contexts with their child c...
│   └── StoryAnalyzer [module]
├── Auth
│   ├── OAuthClient [module]
│   └── Strategy [module]
├── Authorization [module]
├── BddSpecs [context]
│   ├── Parser [module]
│   ├── Scenario [schema (non-persisted)]
│   ├── Spec [schema (non-persisted)]
│   ├── SpecProjector [module]
│   ├── Spex [component]
│   │   ├── Error [module]
│   │   ├── Failure [module]
│   │   └── Step [module]
│   ├── Step [schema (non-persisted)]
│   └── Types
│       └── AtomArray [module]
├── Bogus [module]
├── ClientUsers [module]
│   └── ClientUser [module]
├── Code [context]
│   ├── Elixir [module]
│   └── ElixirAst [module]
├── Compile [module]
├── Components [module]
│   ├── Component [module]
│   ├── ComponentRepository [module] Repository for managing Component entities within a project scope. Provides CRUD operations, filtering by type and na...
│   ├── ComponentStatus [module]
│   ├── Dependency [module] Ecto schema representing a directed dependency relationship between two components. Models "source depends on target"...
│   ├── DependencyRepository [module] Repository for managing component dependency relationships within a project scope. Provides CRUD operations for depen...
│   ├── DependencyTree [module] Build nested dependency trees for components by processing them in optimal order. Uses topological sorting to ensure ...
│   ├── DirtyTracker [module]
│   ├── FileInfo [module] Struct representing a file's metadata for sync comparison. **type**: struct
│   ├── HierarchicalTree [module] Build nested hierarchical trees for components based on parent-child relationships. Unlike dependency trees which req...
│   ├── Registry [module] Central registry containing all component type-specific metadata and behavior definitions. Provides the authoritative...
│   ├── SimilarComponent [module] Ecto schema representing a similarity relationship between two components. Similar components serve as design inspira...
│   ├── SimilarComponentRepository [module] Repository for managing similar component relationships within a project scope. Similar components represent design i...
│   └── Sync [module] Synchronizes components from filesystem to database. Parent-child relationships are derived from directory structure.
│       └── FileInfo [module]
├── Content [module]
│   ├── Content [module]
│   ├── ContentRepository [module] Provides data access functions for published Content entities. Handles content retrieval with optional scope filterin...
│   ├── ContentTag [module]
│   ├── Tag [module] Ecto schema representing content tags for categorization and organization. Tags have a many-to-many relationship with...
│   └── TagRepository [module] Query builder module for tag upsert and lookup. Handles tag normalization and conflict resolution on unique constrain...
├── ContentAdmin [module]
│   ├── ContentAdmin [module]
│   └── ContentAdminRepository [module] Provides multi-tenant data access for ContentAdmin entities with account and project scoping. Handles retrieval of co...
├── ContentSync [module]
│   ├── FileWatcher [module] Public API for file watching during development. Monitors local content directories for file changes and triggers Con...
│   │   ├── Impl [module]
│   │   └── Server [module]
│   ├── GitSync [module] Handles Git repository operations for content sync. Clones project's docs_repo to temporary directory for sync operat...
│   ├── HtmlProcessor [module] Validates HTML content structure and checks for disallowed JavaScript elements. Parses HTML using Floki to ensure wel...
│   ├── MarkdownProcessor [module] Converts markdown content to HTML using the Earmark library. Populates the `processed_content` field with the rendere...
│   ├── MetaDataParser [module] Parses sidecar YAML files to extract structured metadata for content files. Reads YAML metadata files and validates t...
│   ├── ProcessorResult [module] Shared result structure for all content processors in the sync pipeline. Contains raw and processed content along wit...
│   └── Sync [module] Agnostic content synchronization pipeline that processes filesystem content into attribute maps. Accepts a directory ...
├── Documents [context]
│   ├── DocumentSpecProjector [other]
│   ├── Field [schema]
│   ├── Function [schema]
│   ├── MarkdownParser [other]
│   ├── Parsers
│   │   ├── ComponentParser [other]
│   │   ├── ContextParser [module]
│   │   ├── DependencyParser [other]
│   │   ├── FieldParser [other]
│   │   ├── FunctionParser [other]
│   │   ├── IssueParser [module]
│   │   ├── LiveviewParser [module]
│   │   └── SurfaceComponentParser [module]
│   ├── QaIssue [module]
│   ├── Registry [other]
│   └── SpecComponent [schema]
├── Encrypted
│   └── Binary [module]
├── Environments [logic]
│   ├── Cli [logic]
│   │   └── TmuxAdapter [logic]
│   ├── Environment [struct]
│   ├── EnvironmentsBehaviour [module]
│   └── Local [module]
├── FileEdits [module]
│   └── FileEdit [module]
├── FrameworkSync [module]
├── Git [module] Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations ...
│   ├── Behaviour [module] Behaviour defining the contract for Git operations with authenticated credentials. This behaviour establishes the int...
│   ├── CLI [module]
│   ├── Cli [module] Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from...
│   ├── URLParser [module]
│   └── UrlParser [module] Parses HTTPS git repository URLs to extract provider information and construct authenticated URLs with injected acces...
├── GitHub [module]
├── Google
│   └── Analytics [module]
├── Integrations [module]
│   ├── Integration [module]
│   ├── IntegrationRepository [module]
│   └── Providers
│       ├── Behaviour [module]
│       ├── GitHub [module]
│       └── Google [module]
├── Invitations [module]
│   ├── Invitation [module]
│   ├── InvitationNotifier [module]
│   └── InvitationRepository [module]
├── Issues [context]
│   ├── Issue [schema]
│   ├── IssuesRepository [repository]
│   └── Projector [module]
├── LocalServer [module]
│   ├── AuthState [module]
│   ├── Config [module]
│   ├── Controllers
│   │   ├── AgentTaskController [module]
│   │   ├── BootstrapController [module]
│   │   ├── HookController [module]
│   │   ├── NotificationController [module]
│   │   ├── PermissionController [module]
│   │   ├── StoryComponentController [module]
│   │   └── StoryLinkageController [module]
│   ├── McpPlug [module]
│   ├── NotificationClient [module]
│   ├── PermissionSocket [module]
│   ├── Plugs
│   │   ├── LocalOnly [module]
│   │   ├── LocalScope [module]
│   │   └── WorkingDir [module]
│   └── Router [module]
├── Mailer [module]
├── McpServers [module] MCP (Model Context Protocol) servers context providing AI agent interfaces to domain functionality. This context serv...
│   ├── AnalyticsAdmin
│   │   └── Tools
│   │       ├── ArchiveCustomDimension [module]
│   │       ├── ArchiveCustomMetric [module]
│   │       ├── CreateCustomDimension [module]
│   │       ├── CreateCustomMetric [module]
│   │       ├── CreateKeyEvent [module]
│   │       ├── DeleteKeyEvent [module]
│   │       ├── GetCustomDimension [module]
│   │       ├── GetCustomMetric [module]
│   │       ├── ListCustomDimensions [module]
│   │       ├── ListCustomMetrics [module]
│   │       ├── ListKeyEvents [module]
│   │       ├── UpdateCustomDimension [module]
│   │       ├── UpdateCustomMetric [module]
│   │       └── UpdateKeyEvent [module]
│   ├── AnalyticsAdminServer [module] MCP server that exposes Google Analytics Admin API tools to AI agents via the Hermes protocol. This server provides c...
│   ├── Architecture
│   │   ├── ArchitectureMapper [module] Response formatter for architecture-related MCP server tools. Transforms component data, architecture summaries, vali...
│   │   └── Tools
│   │       ├── AnalyzeStories [module]
│   │       ├── GetComponentView [module] MCP tool that generates detailed markdown views of components including metadata, dependency relationships, child com...
│   │       ├── GetSpec [module] MCP tool that retrieves a component specification with metadata and content. Accepts either a module name or componen...
│   │       ├── ListSpecs [module] MCP tool that lists all component specs in the project with optional filtering by component type.
│   │       ├── ReviewArchitectureDesign [module] MCP tool that reviews current architecture design against best practices, providing feedback on surface-to-domain sep...
│   │       ├── StartArchitectureDesign [module] MCP tool that initiates a guided architecture design session by generating a comprehensive prompt for AI agents. Maps...
│   │       └── ValidateDependencyGraph [module] MCP tool that validates the component dependency graph for circular dependencies. Returns validation result indicatin...
│   ├── ArchitectureServer [module] MCP (Model Context Protocol) server that exposes architecture analysis tools to AI agents. Provides tools for validat...
│   │   ├── CreateSpec [module] Creates a new component spec file from template and syncs to database. Generates spec file at appropriate path based ...
│   │   ├── DeleteSpec [module] Deletes a component spec file and removes component from database. Removes spec file from filesystem and cascades del...
│   │   ├── GetArchitectureSummary [module] Returns structured architecture metrics for programmatic use. Includes context count, total component count, dependen...
│   │   ├── GetComponentImpact [module] Analyzes the impact of modifying a component by tracing all dependents transitively. Returns direct dependents, trans...
│   │   ├── GetComponentView [module] MCP tool that generates a detailed markdown view of a component and its full dependency tree. Shows component metadat...
│   │   ├── GetSpec [module] Retrieves a specific component spec by module name or ID. Returns component metadata, file path, and current spec fil...
│   │   ├── ListSpecs [module] Lists all component specs in the project scope. Returns component metadata from database (module_name, type, descript...
│   │   └── ValidateDependencyGraph [module] Validates the component dependency graph for circular dependencies. Returns validation result indicating success or l...
│   ├── Components
│   │   ├── ComponentsMapper [module] Maps component data to MCP responses in JSON format for programmatic access. This module handles all response formatt...
│   │   └── Tools
│   │       ├── AddSimilarComponent [module]
│   │       ├── ArchitectureHealthSummary [module] MCP tool that provides a comprehensive health assessment of the system architecture. Analyzes story coverage (entry/d...
│   │       ├── ContextStatistics [module] MCP tool that provides statistical overview of component contexts including story counts, dependency counts (incoming...
│   │       ├── CreateComponent [module]
│   │       ├── CreateComponents [module]
│   │       ├── CreateDependencies [module] MCP tool for batch creation of component dependencies. Accepts multiple dependency definitions and returns successful...
│   │       ├── CreateDependency [module] MCP tool that creates dependency relationships between components and validates the dependency graph for circular dep...
│   │       ├── DeleteComponent [module] MCP tool that deletes a component from the system. Validates scope (active account and project), retrieves the compon...
│   │       ├── DeleteDependency [module] MCP tool for deleting dependency relationships between components. This tool exposes the dependency deletion capabili...
│   │       ├── GetComponent [module]
│   │       ├── ListComponents [module] MCP tool that lists all components in a project, providing component summaries with essential metadata.
│   │       ├── OrphanedContexts [module] Lists all contexts with no user story and no dependencies. This MCP tool identifies orphaned contexts - components of...
│   │       ├── RemoveSimilarComponent [module] MCP tool that removes a similar component relationship between two components. This tool is exposed via the Component...
│   │       ├── ReviewContextDesign [module] MCP tool that reviews the current context design against best practices and provides architectural feedback. Analyzes...
│   │       ├── ShowArchitecture [module] MCP tool that provides comprehensive system architecture visualization including dependency graphs, component relatio...
│   │       ├── StartContextDesign [module] MCP tool that initiates guided context design sessions for AI agents. Generates a structured prompt containing unsati...
│   │       └── UpdateComponent [module]
│   ├── ComponentsServer [module] MCP (Model Context Protocol) server that exposes component management, dependency tracking, architecture analysis, an...
│   ├── Formatters [module] Formats responses and errors for MCP servers in a hybrid format combining human-readable summaries with structured da...
│   ├── Issues
│   │   ├── IssuesMapper [module]
│   │   └── Tools
│   │       └── CreateIssue [module]
│   ├── IssuesServer [module]
│   ├── Stories
│   │   ├── StoriesMapper [module] Maps story data to MCP responses using a hybrid format that combines human-readable summaries with structured JSON da...
│   │   └── Tools
│   │       ├── AddCriterion [module]
│   │       ├── ClearStoryComponent [module]
│   │       ├── CreateStories [module] MCP tool for batch creation of user stories. Processes multiple story creation requests in a single operation, return...
│   │       ├── CreateStory [module] MCP tool for creating user stories with title, description, and acceptance criteria. This tool transforms acceptance ...
│   │       ├── DeleteCriterion [module] MCP tool that deletes an acceptance criterion from a story. Provides protection against deleting verified (locked) cr...
│   │       ├── DeleteStory [module] MCP tool that permanently deletes a user story from the system. This tool integrates with the Hermes MCP framework to...
│   │       ├── GetStory [module] MCP tool that retrieves a single story by ID with full details including acceptance criteria. Part of the Stories MCP...
│   │       ├── ListProjectTags [module]
│   │       ├── ListStories [module] MCP tool for listing stories in a project with pagination and optional search filtering. Returns full story details i...
│   │       ├── ListStoryTitles [module] Lists story titles in a project (lightweight). Returns just ID, title, and component_id - no criteria or full descrip...
│   │       ├── SetStoryComponent [module] MCP tool for linking a story to a component that implements it. This tool allows AI agents to track which components ...
│   │       ├── StartStoryInterview [module] MCP tool that initiates an interactive interview session to help develop and refine user stories. Acts as an expert P...
│   │       ├── StartStoryReview [module] MCP tool that initiates a comprehensive review of user stories in a project by generating an AI prompt with review cr...
│   │       ├── StartStorySession [module]
│   │       ├── TagStories [module]
│   │       ├── UpdateCriterion [module] MCP tool for updating the description of existing acceptance criteria. Protects verified (locked) criteria from modif...
│   │       └── UpdateStory [module]
│   ├── StoriesServer [module] MCP server that exposes user story management tools to AI agents via the Hermes framework. Provides CRUD operations f...
│   └── Validators [module]
├── Notifications [module]
│   ├── PermissionRequest [module]
│   └── PushSubscription [module]
├── Oauth
│   ├── AccessGrant [module]
│   ├── AccessToken [module]
│   └── Application [module]
├── Paths [module]
├── Problems [context]
│   ├── Problem [schema]
│   ├── ProblemAssigner [module]
│   ├── ProblemConverter [module] Utility module for transforming heterogeneous tool outputs (Credo, compiler warnings, test failures) into normalized ...
│   ├── ProblemRenderer [module] Utility module for rendering Problem structs into human and AI-readable formats. Transforms normalized problems from ...
│   └── ProblemRepository [module] Repository module providing scoped data access operations for problems. Handles database queries with proper scope fi...
├── ProjectCoordinator [module]
│   ├── ComponentAnalyzer [module]
│   ├── Dispatch [module] Translates a `%Requirement{}` from NextActionable into an executable prompt (command) or a validation pass (evaluate)...
│   ├── ImplementationStatus [module]
│   └── NextActionable [module] Finds the next actionable requirement for a project by recursively descending through entities. Uses the `scope` fiel...
├── ProjectSetupWizard [module]
│   ├── GithubIntegration [module]
│   └── ScriptGenerator [module]
├── ProjectSync [module] Public API for orchestrating synchronization of the entire project from filesystem to database and maintaining real-t...
│   ├── ChangeHandler [module] Routes file change events to appropriate synchronization operations. This is a pure functional module that determines...
│   ├── FileWatcherServer [module] Singleton GenServer that manages the FileSystem watcher process and debounces file change events. This module uses `u...
│   ├── StatusWriter [module]
│   └── Sync [module] Implementation module that performs the actual synchronization logic. This is a pure functional module with no state ...
├── Projects [module]
│   └── Project [module]
├── Quality [context]
│   ├── Compile [other]
│   ├── Result [module] Embedded schema representing quality check results with scoring from 0.0 to 1.0. Supports both pass/fail and incremen...
│   ├── SpecTestAlignment [module] Validates that test implementations align with Test Assertions defined in component specifications. Ensures tests mat...
│   └── Tdd [module] Validates test execution state for TDD workflows. Handles parsing test results, validating test run data, and checkin...
├── Release [module]
├── Repo [module]
├── Requirements [module] Manages component requirement checking, persistence, and workflow queries. Requirements are computed from checker mod...
│   ├── AcceptedIssuesChecker [module]
│   ├── AllBddSpecsPassingChecker [module]
│   ├── AllStoriesCompleteChecker [module]
│   ├── ArtifactExistenceChecker [module]
│   ├── BddSpecExistenceChecker [module]
│   ├── BddSpecPassingChecker [module]
│   ├── CheckerBehaviour [module] Defines the interface contract for requirement checker modules. Checker modules implement the `check/4` callback to e...
│   ├── CheckerType [module] Custom Ecto type that validates and converts requirement checker modules. Provides type casting, loading, and dumping...
│   ├── Checkers
│   │   └── DocumentValidityChecker [logic]
│   ├── ComponentCompleteChecker [module]
│   ├── ComponentLinkedChecker [module]
│   ├── ContextReviewFileChecker [module]
│   ├── ContextReviewValidityChecker [module]
│   ├── DependencyChecker [module] Checks whether a component's dependencies have all their requirements satisfied. Implements the `CheckerBehaviour` to...
│   ├── DocumentValidityChecker [module] Validates that a document file contains valid content according to its document type definition. Uses `CodeMySpec.Doc...
│   ├── FileExistenceChecker [module] Implements the CheckerBehaviour to verify that required files exist for a component. Checks for spec files, code file...
│   ├── HierarchicalChecker [module] Implements `CheckerBehaviour` to verify hierarchical component requirements by recursively checking that all child co...
│   ├── IncomingIssuesChecker [module]
│   ├── ProjectQaChecker [module]
│   ├── QaJourneyExecuteChecker [module]
│   ├── QaJourneyPlanChecker [module]
│   ├── QaJourneyWallabyChecker [module]
│   ├── Registry [module]
│   ├── Requirement [module] Embedded schema representing a component requirement instance with its satisfaction status. Created from RequirementD...
│   ├── RequirementDefinition [schema]
│   ├── RequirementDefinitionData [data]
│   ├── RequirementsFormatter [module]
│   ├── RequirementsRegistry [module] Central registry containing requirement definitions for component and context types. Provides the authoritative sourc...
│   ├── RequirementsRepository [module] Repository module for managing persisted component requirement satisfaction status. Provides CRUD operations for requ...
│   ├── SpecTestAlignmentChecker [module]
│   ├── StoryQaChecker [module]
│   ├── Sync [module]
│   └── TestStatusChecker [module]
├── Rules [module]
│   └── RulesComposer [module]
├── Sessions [context]
│   ├── Session [schema]
│   ├── SessionStack [module]
│   ├── SessionType [module]
│   └── SessionsRepository [repository]
├── Specs
│   ├── Field [module] Embedded schema representing a schema field. **Fields**: | Field | Type | Required | Description | | ----------- | --...
│   ├── FieldParser [logic]
│   ├── Function [module] Embedded schema representing a function from a spec. **Fields**: | Field | Type | Required | Description | | --------...
│   ├── FunctionParser [logic]
│   ├── Spec [module] Embedded schema representing a parsed spec file. **Fields**: | Field | Type | Required | Description | | ------------...
│   └── SpecParser [logic]
├── StaticAnalysis [context]
│   ├── AnalyzerBehaviour [module]
│   ├── Analyzers
│   │   ├── Credo [module]
│   │   ├── Sobelow [module]
│   │   └── SpecAlignment [module]
│   └── Runner [module]
├── Stories [context]
│   ├── Markdown [module] Handles parsing and formatting of user stories in markdown format for import/export functionality. Provides clean sep...
│   ├── RemoteClient [module]
│   ├── RemoteSync [module]
│   ├── StoriesRepository [module] Repository for managing Story entities within a project scope. Provides CRUD operations, scoped queries, composable q...
│   └── Story [module] Ecto schema representing user stories in the system. Stories capture requirements with titles, descriptions, and acce...
├── Tags [context]
│   ├── StoryTag [module]
│   ├── Tag [module]
│   └── TagRepository [module]
├── TestContext [context]
├── Tests [module] The Tests context provides a functional interface for executing ExUnit tests with real-time streaming and structured ...
│   ├── TestError [module] Embedded schema representing test failure information from ExUnit test runs. Captures error details including file lo...
│   ├── TestResult [module] Embedded Ecto schema representing an individual test result from ExUnit execution. Captures test metadata (title, ful...
│   ├── TestRun [module] Embedded schema representing a single test execution run with execution metadata, test statistics, results, and failu...
│   ├── TestServer [genserver]
│   └── TestStats [module] Embedded schema for capturing ExUnit test execution statistics and timing information. This struct is used within Tes...
├── Transcripts [module]
│   ├── ClaudeCode
│   │   ├── Entry [module]
│   │   ├── FileExtractor [module]
│   │   ├── Parser [module]
│   │   ├── ToolCall [module]
│   │   └── Transcript [module]
│   ├── Replayer [module]
│   └── TaskIdentifier [module]
├── UserPreferences [module]
│   └── UserPreference [module]
├── Users [module]
│   ├── Scope [module]
│   ├── User [module]
│   ├── UserNotifier [module]
│   └── UserToken [module]
├── Utils [module]
│   ├── Data [module]
│   ├── ModuleType [module]
│   └── Paths [module] Utilities for resolving and working with file system paths within the project, particularly for determining context p...
├── Validation [context]
│   ├── Pipeline [module] Runs the generic validation pipeline on a set of files. Categorizes files by type, compiles the project, then runs te...
│   └── TaskEvaluator [module] Evaluates agent tasks. Two entry points for the two hook events: `evaluate_component/2` resolves a component task fro...
└── Vault [module]
CodeMySpecWeb [module]
├── AccountLive
│   ├── Components
│   │   ├── AccountsBreadcrumb [module]
│   │   ├── MembersList [module]
│   │   └── Navigation [module]
│   ├── Form [module]
│   ├── Index [module]
│   ├── Invitations [module]
│   ├── Manage [module]
│   ├── Members [module]
│   └── Picker [module]
├── AppLive
│   └── Overview [module]
├── Application [module]
├── ArchitectureLive
│   └── Index [module]
├── ChangesetJSON [module]
├── ComponentLive
│   ├── Form [module]
│   ├── Index [module]
│   └── SimilarComponentsSelector [module]
├── ContentAdminLive
│   ├── Index [module]
│   └── Show [module]
├── ContentLive
│   ├── Index [module]
│   ├── Pages
│   │   └── Methodology [module]
│   └── Public [module]
├── ContentSyncController [module]
├── CoreComponents [module]
├── Endpoint [module]
├── ErrorHTML [module]
├── ErrorJSON [module]
├── FallbackController [module]
├── Gettext [module]
├── IntegrationsController [module]
├── InvitationsLive
│   ├── Accept [module]
│   ├── Components
│   │   └── PendingInvitations [module]
│   └── Form [module]
├── Layouts [module]
├── Live
│   └── CurrentPathHook [module]
├── NotificationController [module]
├── OAuthController [module]
├── OAuthHTML [module]
├── PageController [module]
├── PageHTML [module]
├── PermissionChannel [module]
├── PermissionController [module]
├── PermissionLive
│   └── Show [module]
├── Plugs
│   └── ProjectScopeOverride [module]
├── Presence [module]
├── ProjectController [module]
├── ProjectLive
│   ├── Components
│   │   └── ProjectBreadcrumb [module]
│   ├── Form [module]
│   ├── Index [module]
│   ├── Picker [module]
│   ├── SetupWizard [module]
│   └── Show [module]
├── PushSubscriptionController [module]
├── Router [module]
├── SessionChannel [module]
├── StoriesChannel [module]
├── StoriesController [module]
├── StoriesJSON [module]
├── StoryLive
│   ├── Form [module]
│   ├── Import [module]
│   ├── Index [module]
│   ├── Scheduler [module]
│   └── Show [module]
├── Telemetry [module]
├── TypeaheadComponent [module]
├── UserAuth [module]
├── UserController [module]
├── UserLive
│   ├── Confirmation [module]
│   ├── Login [module]
│   ├── Registration [module]
│   └── Settings [module]
├── UserPreferenceLive
│   └── Form [module]
├── UserSessionController [module]
└── UserSocket [module]
Mix
└── Tasks
    ├── GenerateDemo [module]
    ├── GetJohns10Token [module]
    └── SetStoryComponent [module]
Sessions
├── Session [module] Ecto schema for agent task sessions. Tracks type (agent task module), agent, environment, execution mode, status life...
├── SessionStack [module] Filesystem-based session stack that controls stop hook behavior. Each session is a directory under .code_my_spec/inte...
└── SessionType [module] Custom Ecto type mapping agent task module atoms to string representations. Validates against known agent task modules.
StructIntrospector [module]
TestAppWeb
└── DashboardLive [liveview] Dashboard view