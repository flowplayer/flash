/*
 * Copyright 2008 Adobe Systems Inc., 2008 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * Contributor(s):
 *   Zwetan Kjukov <zwetan@gmail.com>.
 *   Marc Alcaraz <ekameleon@gmail.com>.
 */

package com.google.analytics.data
{

     /* TODO: 
      *  - need info for what can contain keys and values
      *   are keys only alpha chars and value only numbers ?
      * - maybe refactor so we have a X10Module composed of X10Objects
      */
     
    /**
     * Google Analytics Tracker Code (GATC)'s extensible data component.
     * This class encapsulates all logic for setting and clearing extensible
     * data and generating the resultant URL parameter.
     */
    public class X10
    {
    	/**
    	 * @private
    	 */
        private var _projectData:Object;
        
        // Type qualifiers for each of the types.
        
        /**
         * @private
         */
        private var _key:String   = "k";
        
        /**
         * @private
         */        
        private var _value:String = "v";
        
        /**
         * @private
         */        
        private var _set:Array    = [ _key, _value ];
        
        // Delimiters for wrapping a set of values belonging to the same type.
        
        /**
         * @private
         */
        private var _delimBegin:String = "(";
        
        /**
         * @private
         */        
        private var _delimEnd:String   = ")";
        
        // Delimiter between two consecutive num/value pairs.
        
        /**
         * @private
         */        
        private var _delimSet:String = "*";
        
        // Delimiter between a num and its corresponding value.
        
        /**
         * @private
         */        
        private var _delimNumValue:String = "!";
        
        // Escape character. We're only escaping ), ,(comma), and :, but
        // we'll need an escape character as well, which we've chosen to be ~.
        
        /**
         * @private
         */        
        private var _escapeChar:String = "'";
        
        // Mapping of escapable characters to their escaped forms.
        
        /**
         * @private
         */        
        private var _escapeCharMap:Object;
        
        /**
         * @private
         */        
        private var _minimum:int;
        
        /**
         * @private
         */
        private var _hasData:int;
        
        /**
         * Creates a new X10 instance.
         */
        public function X10()
        {
            _projectData = {};
            
            _escapeCharMap = {};
            _escapeCharMap[_escapeChar]    = "'0" ;
            _escapeCharMap[_delimEnd]      = "'1" ;
            _escapeCharMap[_delimSet]      = "'2" ;
            _escapeCharMap[_delimNumValue] = "'3" ;
            
            _minimum = 1;
        }
        
        /**
         * Internal implementation for setting an X10 data type.
         * @private
         * @param projectId The project ID for which to set a value.
         * @param type The data type for which to set a value.
         * @param num The numeric index for which to set a value.
         * @param value The value to be set into the specified indices.
         */
        private function _setInternal( projectId:Number, type:String, num:Number, value:String ):void
        {
            if( !hasProject(projectId) )
            {
                _projectData[projectId] = {};
            }
            
            if( _projectData[projectId][type] == undefined )
            {
                _projectData[projectId][type] = [];
            }
            
            _projectData[projectId][type][num] = value;
            _hasData += 1;
        }
        
        /**
         * Internal implementation for getting an X10 data type.
         *
         * @private
         * @param projectId The project ID for which to set a value.
         * @param type The data type for which to set a value.
         * @param num The numeric index for which to set a value.
         *
         * @return The stored object at the specified indices.
         *     The value property of this object is the stored value, and
         *     the optional aggregationType property of this object is
         *     the specified custom aggregation type, if any.
         */
        private function _getInternal( projectId:Number, type:String, num:Number ):Object
        {
            if( hasProject(projectId) &&
                _projectData[projectId][type] != undefined )
            {
                return _projectData[projectId][type][num];
            }
            else
            {
                return undefined;
            }
        }
        
        /**
         * Internal implementation for clearing all X10 data of a type from a certain project.
         * @param projectId The project ID for which to set a value.
         * @param type The data type for which to set a value.
         * @private
         */
        private function _clearInternal( projectId:Number, type:String ):void
        {
            if( hasProject(projectId) &&
                _projectData[projectId][type] != undefined )
            {
                _projectData[projectId][type] = undefined;
                
                var isEmpty:Boolean = true;
                var i:int;
                var l:int = _set.length ;
                for( i = 0; i < l ; i++)
                {
                    if( _projectData[projectId][ _set[i] ] != undefined )
                    {
                        isEmpty = false;
                        break;
                    }
                }
                
                if( isEmpty )
                {
                    _projectData[projectId] = undefined;
                    _hasData -= 1;
                }
            }
        }
        
        /**
         * Escape X10 string values to remove ambiguity for special characters.
         * <p>See the <code class="prettyprint">escapeCharMap</code> private member for more detail.</p>
         * @private
         * @param value The string value to be escaped.
         * @return The escaped version of the passed-in value.
         */
        private function _escapeExtensibleValue( value:String ):String
        {
            var result:String = "";
            var i:int;
            var c:String;
            var escaped:String;
            
            for( i = 0; i < value.length; i++ )
            {
                c = value.charAt(i);
                escaped = _escapeCharMap[c];
                
                if( escaped )
                {
                    result += escaped;
                }
                else
                {
                    result += c;
                }
            }
            
            return result;
        }
        
        /**
         * Given a data array for a certain type, render its string encoding.
         * @private
         * @param data An array of num/value pair data.
         * @return The string encoding for this array of data.
         */
        private function _renderDataType( data:Array ):String
        {
            var result:Array = [];
            var str:String;
            var i:int;
            
            // Technically arrays start at 0, but X10 numeric indices start at 1.
            for( i = 0; i < data.length; i++ )
            {
                if( data[i] != undefined )
                {
                    str = "";
                    
                    // Check if we need to append the number. If the last number was
                    // outputted, or if this is the assumed minimum, then we don't.
                    if( i != _minimum && data[i - 1] == undefined )
                    {
                        str += i.toString();
                        str += _delimNumValue;
                    }
                    
                    str += _escapeExtensibleValue(data[i]);
                    result.push( str );
                }
            }
            
            // Wrap things up.
            return _delimBegin + result.join(_delimSet) + _delimEnd;
        }
        
        /**
         * Given a project hashmap, render its string encoding.
         * @private
         * @param project A hashmap of project data keyed by data type.
         * @return The string encoding for this project.
         */
        private function _renderProject( project:Object ):String
        {
            var result:String = "";
            
            // Do we need to output the type string? As an optimization we do not
            // output the type string if it's the first type, or if the previous
            // type was present.
            var needTypeQualifier:Boolean = false;
            var i:int;
            var data:Array;
            var l:int = _set.length ;
            for( i = 0; i < l ; i++ )
            {
                data = project[ _set[i] ];
                if( data )
                {
                    if( needTypeQualifier )
                    {
                        result += _set[i];
                    }
                    result += _renderDataType( data );
                    needTypeQualifier = false;
                }
                else
                {
                    needTypeQualifier = true;
                }
            }
            return result;
        }
        
        
        /**
         * Checking whether a project exists in the current data state.
         * @param projectId The identifier for the project.
         * @return whether this X10 module contains the project at the designated project ID.
         */
        public function hasProject( projectId:Number ):Boolean
        {
            return _projectData[projectId];
        }
        
        /**
         * Indicates if the X10 object has data.
         */
        public function hasData():Boolean
        {
            return ( _hasData > 0 ) ;
        }
        
        /**
         * Wrapper for setting an X10 string key.
         * @param projectId The project ID for which to set a value.
         * @param num The numeric index for which to set a value.
         * @param value The value to be set into the specified indices.
         * @return Whether the key was successfully set.
         */
        public function setKey( projectId:Number, num:Number, value:String ):Boolean
        {
            _setInternal( projectId, _key, num, value );
            return true;
        }
        
        /**
         * Wrapper for getting an X10 string key.
         *
         * @param projectId The project ID for which to get a value.
         * @param num The numeric index for which to get a value.
         *
         * @return The requested key, null if not found.
         */
        public function getKey( projectId:Number, num:Number ):String
        {
            return _getInternal(projectId, _key, num) as String;
        }
        
        /**
         * Wrapper for clearing all X10 string keys for a given project ID.
         *
         * @param projectId The project ID for which to clear all keys.
         */
        public function clearKey( projectId:Number ):void
        {
            _clearInternal(projectId, _key);
        }
        
        /**
         * Wrapper for setting an X10 integer value.
         * @param projectId The project ID for which to set a value.
         * @param num The numeric index for which to set a value.
         * @param value The value to be set into the specified indices.
         * @return whether the value was successfully set.
         */
        public function setValue( projectId:Number, num:Number, value:Number ):Boolean
        {
        	// note: in JS value was {String}, maybe we should considered using * instead of type Number
            if( Math.round(value) != value || isNaN(value) || value == Infinity )
            {
                return false;
            }
            _setInternal( projectId, _value, num, value.toString() );
            return true;
        }
        
        /**
         * Wrapper for getting an X10 integer value.
         * @param projectId The project ID for which to get a value.
         * @param num The numeric index for which to get a value.
         * @return The requested value in number form, null if not found.
         */
        public function getValue( projectId:Number, num:Number ):*
        {
        	//
        	// TODO:
            // - problem here, if we return a type Number we cannot return null
            //   (null will be automatically casted to a Number and then zero)
            // - need to check the details why getValue can or have to return null
        	//
            var value:* = _getInternal(projectId, _value, num);
            
            if( value == null )
            {
                return null;
            }
            
            return Number( value );
        }
        
        /**
         * Wrapper for clearing all X10 integer values for a given project ID.
         * @param projectId The project ID for which to clear all values.
         */
        public function clearValue( projectId:Number ):void
        {
            _clearInternal( projectId, _value );
        }
        
        /**
         * Generates the URL parameter string for the current internal extensible data state.
         * @return Encoded extensible data string.
         */
        public function renderUrlString():String
        {
            
            // TODO:
            // - rename to toURLString, better naming
            // - add a static parseURLString method (even if it's only to help debugging,testing)
            // - check if we need to sort the data, see X10Test.testRenderUrlString7()
            //
            
            var result:Array = [];
            var projectId:String;
            
            for( projectId in _projectData )
            {
                if( hasProject( Number(projectId) ) )
                {
                    result.push( projectId + _renderProject(_projectData[projectId]) );
                }
            }
            
            return result.join("");
        }
        
        /**
         * Render the merged url String representation of the X10 passed-in object.
         * @return The merged url String representation of the X10 passed-in object.
         */
        public function renderMergedUrlString( extObject:X10 = null ):String
        {
            if( !extObject )
            {
                return renderUrlString();
            }
            
            var result:Array = [ extObject.renderUrlString() ];
            var projectId:String;
            
            for( projectId in _projectData )
            {
                if( hasProject( Number(projectId) ) &&
                    !extObject.hasProject( Number(projectId) ) )
                {
                    result.push( projectId + _renderProject(_projectData[projectId]) );
                }
            }
            
            return result.join("");
        }
        
    }
}

