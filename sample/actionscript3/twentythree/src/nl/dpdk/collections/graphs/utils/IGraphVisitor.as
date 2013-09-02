/*Copyright (c) 2008 De Pannekoek en De Kale B.V.,  www.dpdk.nlPermission is hereby granted, free of charge, to any person obtaining anl.dpdk.collections.trees.graphs.IGraphVisitorSoftware"), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included inall copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS ORIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THEAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHERLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS INTHE SOFTWARE.*/package nl.dpdk.collections.graphs.utils {	import nl.dpdk.collections.graphs.GraphEdge;	import nl.dpdk.collections.graphs.GraphNode;	/**	 * Used with the specialized BreadthFirstSearch and DepthFirstSearch classes for graphs.	 * These allow for more fine grained processing of the graph, including processing of GraphNodes and GraphEdges.	 * @author rolf	 */	public interface IGraphVisitor {		/**		 * process nodes before any other processing is done on the edges		 */		function visitNodeEarly(node : GraphNode) : void;		/**		 * process an edge of a node		 */		function visitEdge(edge : GraphEdge) : void;		/**		 * process nodes after all processing is done in earlier stages		 */		function visitNodeLate(node : GraphNode) : void;	}}