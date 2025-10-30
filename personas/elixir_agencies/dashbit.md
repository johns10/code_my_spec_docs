# Dashbit Intelligence Report: Comprehensive Research for Strategic Outreach

José Valim's Dashbit represents the most influential force in the Elixir ecosystem, operating a unique consultancy-to-open-source model that's experiencing significant growth pressures in 2025. **The company currently faces a 12-month waiting list for their core service**, presenting immediate opportunities for strategic partnerships around scaling and operational efficiency. Their recent launch of Tidewave, an AI-powered development platform, signals major innovation investments that create multiple collaboration entry points.

Dashbit has achieved rare market positioning as simultaneously the language creator's consultancy, premier adoption catalyst, and community steward. This combination creates exceptional influence over ecosystem direction while generating sustainable commercial success through their subscription-based model.

## Company positioning and distinctive business model

Dashbit emerged from Plataformatec's 2020 Nubank acquisition as José Valim's vehicle to continue advancing Elixir commercially while maintaining open-source development. Their "virtuous cycle" business model directly funds continuous open-source work through client consulting revenue, creating sustainable ecosystem advancement.

**Core service offering**: The Elixir Development Subscription provides unlimited access to their 4-engineer team for per-seat pricing. As José explains: *"What we do is that we offer a service called Elixir development subscription. The idea is that we help companies (startups and big corporations) to adopt Elixir, and we do that together with open source."*

Their positioning leverages José's unique authority as Elixir's creator, offering clients direct access to the language's architect for architectural decisions, code reviews, and production readiness guidance. This creates unmatched competitive advantages in technical credibility and ecosystem knowledge.

**Revenue streams include**: primary Elixir Development Subscription service, emerging Livebook Teams platform (currently in beta), advisory roles (José serves Remote.com as advisor), and indirect revenue from open-source project development that drives adoption.

The company deliberately limits growth to maintain quality, recently expanding from 3 to 4 engineers for the first time in February 2025. José noted: *"We were partially failing our mission of helping companies adopt Elixir"* due to the 12-month average waiting time, indicating strong demand pressure.

## Leadership team dynamics and current focus areas

**José Valim** serves as Chief Adoption Officer and remains highly active in 2025, having launched Tidewave.ai in April 2025 - an AI development platform that connects assistants directly to web application runtimes via MCP (Model Context Protocol). His current philosophy centers on *"AI for augmentation, not replacement"* and making *"every developer a 10x developer."*

José's recent content reveals fascination with bridging the gap between static code analysis and runtime behavior. He actively uses Claude Code and GitHub Copilot daily, applying AI for Figma design implementation, landing page copy, and cross-platform porting, while maintaining critical oversight of all AI-generated code.

**Wojtek Mach** (Creator of Req, Ecto team member) focuses on HTTP client architecture and API integration patterns. His Req library demonstrates Dashbit's "batteries-included" philosophy with extensibility through steps-based architecture. He's targeting Req v1.0 release in 2025.

**Jonatan Kłosko** (Creator of Livebook and Bumblebee) brings machine learning integration expertise and collaborative development environment innovation. Notably young (still in college) but professionally contributing at senior levels, he's targeting Livebook v1.0 release alongside Python integration efforts.

**Steffen Deusch** (newest addition, Phoenix/LiveView teams member) focuses on developer onboarding experience, authentication, and security. He's leading Phoenix v1.8 development with improved LiveView generators.

Their extended team includes Guillaume Duboc (working on type system development), Hugo Baraúna and Alexandre de Souza (developing Livebook Teams commercial service).

## Technical architecture philosophy and development standards

Dashbit advocates for **Phoenix contexts as core organizational patterns**, emphasizing encapsulation of business domain boundaries rather than scattering logic across controllers. José explains: *"When building a Phoenix project, we are first and foremost building an Elixir application. Phoenix's job is to provide a web interface into our Elixir application."*

Their **LiveView optimization techniques** have achieved 3-30x rendering performance improvements through static vs dynamic content splitting, keyed comprehensions, and component optimization. They prioritize server-side state management with WebSocket persistence, believing most web applications naturally have server state through databases.

**Code quality practices** emphasize explicit contracts over heavy mocking, property-based testing integration, and continuous integration across multiple Elixir/OTP versions. Their testing philosophy advocates for "contract-based mocking" that pushes stubs closer to production behavior.

**OTP patterns** focus on GenServer client/server API separation, supervisor trees for fault tolerance, and Registry + DynamicSupervisor patterns for scalable process management. They emphasize "let it crash" mentality with supervisor recovery and explicit error types.

**Performance philosophy** extends beyond production to development-time performance, expecting sub-millisecond response times as standard and prioritizing concurrency utilization across all tooling.

## Current growth challenges and operational pressures

Dashbit faces significant scaling constraints despite strong market demand. Their **12-month average waiting list** demonstrates market need exceeding capacity, prompting their first team expansion in February 2025. José acknowledged: *"We were partially failing our mission of helping companies adopt Elixir"* due to these capacity limitations.

**Operational challenges include**: balancing quality versus growth, managing subscription demand with limited team resources, resolving Livebook Teams beta deployment issues (users reporting "Unable to deploy app to app server" errors), and creating educational content for new LiveView developers.

Their **2025 strategic priorities** target completing type inference by Elixir v1.19 (May 2025), releasing Phoenix v1.8 with improved onboarding, launching Livebook Teams commercially, and advancing AI integration across their ecosystem.

**Resource allocation tensions** between client work and open-source contributions create ongoing operational challenges. Their business model requires balancing commercial success with community stewardship, making efficient processes essential for sustainable growth.

## AI integration philosophy and tooling perspectives

José's **Tidewave launch** represents major investment in AI-powered development workflows, specifically addressing limitations of current AI tools that "constrain themselves to static code understanding." His vision extends beyond code intelligence to "runtime intelligence" where AI understands logs, databases, WebSocket connections, and background jobs in real-time.

**Current AI tool usage** includes Claude Code and GitHub Copilot for daily development work, with specific applications in design implementation, content creation, and cross-platform porting. However, he maintains critical oversight: *"At the end of the day, I am not using AI to deliver something I wouldn't have delivered myself."*

**Key AI perspectives** include viewing testing with AI as requiring deeper business domain understanding, noting current tools treat tests as "self-serving code" rather than business alignment tools, and emphasizing the importance of local development environments: *"Localhost is not going anywhere."*

His **interoperability focus** for 2025 emphasizes collaboration between languages and platforms while maintaining Erlang VM advocacy. The upcoming "page intelligence" feature in Tidewave aims to provide AI understanding of delivered user experiences, not just code structure.

## Community influence and ecosystem leadership

Dashbit maintains unparalleled influence in the Elixir ecosystem through José's continued role as language creator and their team's core contributions to major projects including Phoenix, Ecto, Broadway, Livebook, and Nx. Their **mission statement** explicitly targets advancing "the Elixir ecosystem through continuous adoption and sustainable open source development."

**Major community contributions** include funding research at DCC/UFMG's Compilers Laboratory in Brazil, co-sponsoring the Elixir Outreach Program ($5,000 of $7,000 budget), and maintaining leadership positions across multiple core projects.

**Conference leadership** includes José's regular keynote speaking at ElixirConf US, ElixirConf EU, and international conferences, with upcoming presentations at ElixirConf EU 2025 (Kraków) and ElixirConf US 2025 (Orlando). His talks typically focus on architectural patterns, type system development, and ecosystem direction.

**Industry relationships** include partnerships with Chris McCord (Phoenix framework collaboration), official sponsorship of the Erlang Ecosystem Foundation, and advisory roles with companies like Remote.com. They maintain active collaboration with university research programs and international conference organizations.

## Strategic outreach opportunities and optimal timing

**Immediate opportunities** center on their current growth pressure and scaling challenges. The 12-month waiting list creates clear pain points around operational efficiency, team productivity, and service delivery automation. Their recent team expansion creates new coordination and process optimization needs.

**AI integration support** aligns with their Tidewave development and José's vision for enhanced developer workflows. Tools complementing their MCP server approach, integration opportunities with runtime intelligence, and solutions for the "context-switching" problems they've identified represent high-value collaboration areas.

**Beta product support** around Livebook Teams deployment reliability, infrastructure solutions for scaling beta products, and quality assurance automation for multiple simultaneous v1.0 releases create immediate technical collaboration opportunities.

**Community and adoption support** includes solutions for creating educational content at scale, tools addressing "common problems faced by new LiveView developers," and conference presentation automation, aligning with their explicit community leadership role.

**Optimal contact approaches** include reaching out via contact@dashbit.co with company details and specific value propositions, or liveview@dashbit.co for LiveView-specific solutions. They explicitly encourage early access partnership discussions for ElixirKit and NimbleZTA projects.

**Timing considerations** favor immediate outreach during their current growth and innovation phase, with follow-up opportunities post-ElixirConf EU when they'll announce major developments. Avoid mid-May during the Elixir v1.19 release preparation period.

## Conclusion

Dashbit represents a unique strategic opportunity at an inflection point of growth, innovation, and operational scaling challenges. Their combination of technical authority, community influence, and immediate business pressures creates multiple collaboration entry points. José's leadership in both AI integration and type system development positions them at the forefront of programming language evolution, while their scaling challenges present clear opportunities for operational partnership. The current timing, with recent team expansion and major product launches, makes this an optimal moment for strategic engagement focused on enabling their continued ecosystem leadership while addressing immediate operational constraints.